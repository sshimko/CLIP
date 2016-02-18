/**
 * @file   rpminfo.c
 * @brief  rpminfo probe
 * @author "Daniel Kopecek" <dkopecek@redhat.com>
 *
 * 2010/06/13 dkopecek@redhat.com
 *  This probe is able to process a rpminfo_object as defined in OVAL 5.4 and 5.5.
 *
 */

/*
 * Copyright 2009 Red Hat Inc., Durham, North Carolina.
 * All Rights Reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Authors:
 *      "Daniel Kopecek" <dkopecek@redhat.com>
 */

/*
 * rpminfo probe:
 *
 *  rpminfo_object(string name)
 *
 *  rpminfo_state(string name,
 *                string arch,
 *                string epoch,
 *                string release,
 *                string version,
 *                string evr,
 *                string signature_keyid
 *                string extended_status OVAL >= 5.10
 *              )
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <regex.h>

/* RPM headers */
#include <rpm/rpmdb.h>
#include <rpm/rpmlib.h>
#include <rpm/rpmts.h>
#include <rpm/rpmmacro.h>
#include <rpm/rpmlog.h>
#include <rpm/header.h>

#ifndef HAVE_HEADERFORMAT
# define HAVE_LIBRPM44 1 /* hack */
# define headerFormat(_h, _fmt, _emsg) headerSprintf((_h),( _fmt), rpmTagTable, rpmHeaderFormats, (_emsg))
#endif

#ifndef HAVE_RPMFREECRYPTO
# define rpmFreeCrypto() while(0)
#endif

#ifndef HAVE_RPMFREEFILESYSTEMS
# define rpmFreeFilesystems() while(0)
#endif

/* SEAP */
#include <seap.h>
#include <probe-api.h>
#include <probe/probe.h>
#include <probe/option.h>
#include "probe/entcmp.h"
#include <alloc.h>
#include <common/assume.h>
#include "common/debug_priv.h"


struct rpminfo_req {
        char *name;
        oval_operation_t op;
};

struct rpminfo_rep {
        char *name;
        char *arch;
        char *epoch;
        char *release;
        char *version;
        char *evr;
        char *signature_keyid;
	char extended_name[1024];
};

struct rpminfo_global {
        rpmts           rpmts;
        pthread_mutex_t mutex;
};

#define RPMINFO_LOCK	  \
	do { \
		int prev_cancel_state = -1; \
		if (pthread_mutex_lock(&g_rpm.mutex) != 0) { \
			dE("Can't lock mutex\n"); \
			return (-1); \
		} \
		pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &prev_cancel_state); \
	} while(0)

#define RPMINFO_UNLOCK	  \
	do { \
		int prev_cancel_state = -1; \
		if (pthread_mutex_unlock(&g_rpm.mutex) != 0) { \
			dE("Can't unlock mutex. Aborting...\n"); \
			abort(); \
		} \
		pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &prev_cancel_state); \
	} while(0)

static struct rpminfo_global g_rpm;
static const char g_keyid_regex_string[] = "Key ID [a-fA-F0-9]{16}";
static regex_t g_keyid_regex;

static void __rpminfo_rep_free (struct rpminfo_rep *ptr)
{
        oscap_free (ptr->name);
        oscap_free (ptr->arch);
        oscap_free (ptr->epoch);
        oscap_free (ptr->release);
        oscap_free (ptr->version);
        oscap_free (ptr->evr);
        oscap_free (ptr->signature_keyid);
}

static void pkgh2rep (Header h, struct rpminfo_rep *r)
{
        errmsg_t rpmerr;
        char *str, *sid;
	char *epoch_override = NULL;
        size_t len;
	regmatch_t keyid_match[1];

        assume_d (h != NULL, /* void */);
        assume_d (r != NULL, /* void */);

        r->name = headerFormat (h, "%{NAME}", &rpmerr);
        r->arch = headerFormat (h, "%{ARCH}", &rpmerr);
        r->epoch = headerFormat (h, "%{EPOCH}", &rpmerr);
        r->release = headerFormat (h, "%{RELEASE}", &rpmerr);
        r->version = headerFormat (h, "%{VERSION}", &rpmerr);
	epoch_override = oscap_streq(r->epoch, "(none)") ? "0" : r->epoch;
	snprintf(r->extended_name, 1024, "%s-%s:%s-%s.%s", r->name, epoch_override, r->version, r->release, r->arch);

	len = (strlen(epoch_override) +
               strlen (r->release) +
               strlen (r->version) + 2);

        str = oscap_alloc (sizeof (char) * (len + 1));
        snprintf (str, len + 1, "%s:%s-%s",
		epoch_override,
                  r->version,
                  r->release);

        r->evr = str;

        str = headerFormat (h, "%|SIGGPG?{%{SIGGPG:pgpsig}}:{%{SIGPGP:pgpsig}}|", &rpmerr);

	if (regexec(&g_keyid_regex, str, 1, keyid_match, 0) != 0) {
		sid = NULL;
		dW("Failed to extract the Key ID value: regex=\"%s\", string=\"%s\"\n",
		   g_keyid_regex_string, str);
	} else {
		size_t keyid_start, keyid_length;

		if (keyid_match[0].rm_so < 0 || keyid_match[0].rm_eo < 0)
			sid = NULL;
		else {
			keyid_start = keyid_match[0].rm_so + strlen("Key ID ");
			keyid_length = keyid_match[0].rm_eo - keyid_start;
			sid = str + keyid_start;
			sid[keyid_length] = '\0';
		}
	}

        r->signature_keyid = strdup(sid != NULL ? sid : "0");
        oscap_free (str);
}

/*
 * req - Structure containing the name of the package.
 * rep - Pointer to rpminfo_rep structure pointer. An
 *       array of rpminfo_rep structures will be allocated
 *       here.
 *
 * The return value on error is -1. Otherwise the number of
 * rpminfo_rep structures allocated in *rep is returned.
 */
static int get_rpminfo (struct rpminfo_req *req, struct rpminfo_rep **rep)
{
	rpmdbMatchIterator match;
	Header pkgh;
	int ret = 0, i;

        RPMINFO_LOCK;

        ret = -1;

        switch (req->op) {
        case OVAL_OPERATION_EQUALS:
                match = rpmtsInitIterator (g_rpm.rpmts, RPMTAG_NAME, (const void *)req->name, 0);

                if (match == NULL) {
                        ret = 0;
                        goto ret;
                }

                ret = rpmdbGetIteratorCount (match);

                break;
	case OVAL_OPERATION_NOT_EQUAL:
                match = rpmtsInitIterator (g_rpm.rpmts, RPMDBI_PACKAGES, NULL, 0);
                if (match == NULL) {
                        ret = 0;
                        goto ret;
                }

                if (rpmdbSetIteratorRE (match, RPMTAG_NAME, RPMMIRE_GLOB, "*") != 0)
                {
                        ret = -1;
                        goto ret;
                }

                break;
        case OVAL_OPERATION_PATTERN_MATCH:
                match = rpmtsInitIterator (g_rpm.rpmts, RPMDBI_PACKAGES, NULL, 0);

                if (match == NULL) {
                        ret = 0;
                        goto ret;
                }

                if (rpmdbSetIteratorRE (match, RPMTAG_NAME, RPMMIRE_REGEX,
                                        (const char *)req->name) != 0)
                {
                        ret = -1;
                        goto ret;
                }

                break;
        default:
                /* not supported */
                ret = -1;
                goto ret;
        }

        if (ret != -1) {
                /*
                 * We can allocate all memory needed now because we know the number
                 * of results.
                 */
                (*rep) = oscap_realloc (*rep, sizeof (struct rpminfo_rep) * ret);

                for (i = 0; i < ret; ++i) {
                        pkgh = rpmdbNextIterator (match);

                        if (pkgh != NULL)
                                pkgh2rep (pkgh, (*rep) + i);
                        else {
                                /* XXX: emit warning */
                                break;
                        }
                }
        } else {
                ret = 0;

                while ((pkgh = rpmdbNextIterator (match)) != NULL) {
                        (*rep) = oscap_realloc (*rep, sizeof (struct rpminfo_rep) * ++ret);
                        assume_r (*rep != NULL, -1);
                        pkgh2rep (pkgh, (*rep) + (ret - 1));
                }
        }

	match = rpmdbFreeIterator (match);
ret:
        RPMINFO_UNLOCK;
        return (ret);
}

void *probe_init (void)
{
	probe_offline_flags offline_mode = PROBE_OFFLINE_NONE;

        if (rpmReadConfigFiles ((const char *)NULL, (const char *)NULL) != 0) {
                dI("rpmReadConfigFiles failed: %u, %s.\n", errno, strerror (errno));
                return (NULL);
        }

        probe_getoption(PROBEOPT_OFFLINE_MODE_SUPPORTED, NULL, &offline_mode);
        if (offline_mode & PROBE_OFFLINE_RPMDB) {
	        addMacro(NULL, "_dbpath", NULL, getenv("OSCAP_PROBE_RPMDB_PATH"), 0);
        }

        g_rpm.rpmts = rpmtsCreate();
        pthread_mutex_init (&(g_rpm.mutex), NULL);

	if (regcomp(&g_keyid_regex, g_keyid_regex_string, REG_EXTENDED) != 0) {
		dE("regcomp(%s) failed.\n");
		return NULL;
	}

	probe_setoption(PROBEOPT_OFFLINE_MODE_SUPPORTED, PROBE_OFFLINE_CHROOT|PROBE_OFFLINE_RPMDB);

        return ((void *)&g_rpm);
}

void probe_fini (void *ptr)
{
        struct rpminfo_global *r = (struct rpminfo_global *)ptr;

        rpmtsFree(r->rpmts);
	rpmFreeCrypto();
        rpmFreeRpmrc();
        rpmFreeMacros(NULL);
        rpmlogClose();
        pthread_mutex_destroy (&(r->mutex));
	regfree(&g_keyid_regex);

        return;
}

static int collect_rpm_files(SEXP_t *item, const struct rpminfo_rep *rep) {
	SEXP_t *value;
	rpmdbMatchIterator ts;
	Header pkgh;
	rpmfi fi;
	rpmTag tag[2] = { RPMTAG_BASENAMES, RPMTAG_DIRNAMES };
	int i, ret = 0;

	ts = rpmtsInitIterator(g_rpm.rpmts, RPMDBI_PACKAGES, NULL, 0);
	if (ts == NULL) {
		return -1;
	}

	if (rpmdbSetIteratorRE(ts, RPMTAG_NAME, RPMMIRE_STRCMP, rep->name) != 0) {
		ret = -1;
		goto cleanup;
	}
	if (rpmdbSetIteratorRE(ts, RPMTAG_EPOCH, RPMMIRE_STRCMP, rep->epoch) != 0) {
		ret = -1;
		goto cleanup;
	}
	if (rpmdbSetIteratorRE(ts, RPMTAG_VERSION, RPMMIRE_STRCMP, rep->version) != 0) {
		ret = -1;
		goto cleanup;
	}
	if (rpmdbSetIteratorRE(ts, RPMTAG_RELEASE, RPMMIRE_STRCMP, rep->release) != 0) {
		ret = -1;
		goto cleanup;
	}
	if (rpmdbSetIteratorRE(ts, RPMTAG_ARCH, RPMMIRE_STRCMP, rep->arch) != 0) {
		ret = -1;
		goto cleanup;
	}

	while ((pkgh = rpmdbNextIterator(ts)) != NULL) {
		/*
		 * Inspect package files & directories
		 */
		for (i = 0; i < 2; ++i) {
			fi = rpmfiNew(g_rpm.rpmts, pkgh, tag[i], 1);

			while (rpmfiNext(fi) != -1) {
				const char *filepath;
				filepath = rpmfiFN(fi);
				value = probe_entval_from_cstr(
						OVAL_DATATYPE_STRING,
						filepath,
						strlen(filepath)
						);
				if (value != NULL) {
					probe_item_ent_add(item, "filepath", NULL, value);
					SEXP_free(value);
				}
			}
			rpmfiFree(fi);
		}

	}
cleanup:
	ts = rpmdbFreeIterator(ts);
	return ret;
}

int probe_main (probe_ctx *ctx, void *arg)
{
	SEXP_t *val, *item, *ent, *probe_in;
	oval_version_t over;
	int rpmret, i;

        struct rpminfo_req request_st;
        struct rpminfo_rep *reply_st;

	probe_in = probe_ctx_getobject(ctx);
	if (probe_in == NULL)
		return PROBE_ENOOBJ;

	over = probe_obj_get_schema_version(probe_in);

        ent = probe_obj_getent (probe_in, "name", 1);

        if (ent == NULL) {
                return (PROBE_ENOENT);
        }

        val = probe_ent_getval (ent);

        if (val == NULL) {
                dI("%s: no value\n", "name");
                SEXP_free (ent);
                return (PROBE_ENOVAL);
        }

        request_st.name = SEXP_string_cstr (val);
        SEXP_free (val);

        val = probe_ent_getattrval (ent, "operation");

        if (val == NULL) {
                request_st.op = OVAL_OPERATION_EQUALS;
        } else {
                request_st.op = (oval_operation_t) SEXP_number_geti_32 (val);

                switch (request_st.op) {
                case OVAL_OPERATION_EQUALS:
		case OVAL_OPERATION_NOT_EQUAL:
                case OVAL_OPERATION_PATTERN_MATCH:
                        break;
                default:
                        SEXP_free (val);
                        SEXP_free (ent);
                        oscap_free (request_st.name);
                        return (PROBE_EOPNOTSUPP);
                }

                SEXP_free (val);
        }

        if (request_st.name == NULL) {
		SEXP_free (ent);
                switch (errno) {
                case EINVAL:
                        dI("%s: invalid value type\n", "name");
			return PROBE_EINVAL;
                        break;
                case EFAULT:
                        dI("%s: element not found\n", "name");
			return PROBE_ENOELM;
                        break;
		default:
			return PROBE_EUNKNOWN;
                }
        }

        reply_st  = NULL;

        /* get info from RPM db */
        switch (rpmret = get_rpminfo (&request_st, &reply_st)) {
        case 0: /* Not found */
                dI("Package \"%s\" not found.\n", request_st.name);
                break;
        case -1: /* Error */
                dI("get_rpminfo failed\n");

                item = probe_item_create(OVAL_LINUX_RPM_INFO, NULL,
                                         "name", OVAL_DATATYPE_STRING, request_st.name,
                                         NULL);

                probe_item_setstatus (item, SYSCHAR_STATUS_ERROR);
                probe_item_collect(ctx, item);
                break;
        default: /* Ok */
                _A(rpmret   >= 0);
                _A(reply_st != NULL);
                {
                        SEXP_t *name;

                        for (i = 0; i < rpmret; ++i) {
				name = SEXP_string_newf("%s", reply_st[i].name);

				if (probe_entobj_cmp(ent, name) != OVAL_RESULT_TRUE) {
					SEXP_free(name);
					continue;
				}

                                item = probe_item_create(OVAL_LINUX_RPM_INFO, NULL,
                                                         "name",    OVAL_DATATYPE_SEXP, name,
                                                         "arch",    OVAL_DATATYPE_STRING, reply_st[i].arch,
                                                         "epoch",   OVAL_DATATYPE_STRING, reply_st[i].epoch,
                                                         "release", OVAL_DATATYPE_STRING, reply_st[i].release,
                                                         "version", OVAL_DATATYPE_STRING, reply_st[i].version,
                                                         "evr",     OVAL_DATATYPE_EVR_STRING, reply_st[i].evr,
                                                         "signature_keyid", OVAL_DATATYPE_STRING, reply_st[i].signature_keyid,
                                                         NULL);

				/* OVAL 5.10 added extended_name and filepaths behavior */
				if (oval_version_cmp(over, OVAL_VERSION(5.10)) >= 0) {
					SEXP_t *value, *bh_value;
					value = probe_entval_from_cstr(
							OVAL_DATATYPE_STRING,
							reply_st[i].extended_name,
							strlen(reply_st[i].extended_name)
					);
					probe_item_ent_add(item, "extended_name", NULL, value);
					SEXP_free(value);

					/*
					 * Parse behaviors
					 */
					value = probe_obj_getent(probe_in, "behaviors", 1);
					if (value != NULL) {
						bh_value = probe_ent_getattrval(value, "filepaths");
						if (bh_value != NULL) {
							if (SEXP_strcmp(bh_value, "true") == 0) {
								/* collect package files */
								collect_rpm_files(item, &reply_st[i]);

							}
							SEXP_free(bh_value);
						}
						SEXP_free(value);
					}

				}


				SEXP_free(name);
                                __rpminfo_rep_free (&(reply_st[i]));

				if (probe_item_collect(ctx, item)) {
					SEXP_vfree(ent, NULL);
					return 1;
				}
                        }

                        oscap_free (reply_st);
                }
        }

	SEXP_vfree(ent, NULL);
        oscap_free(request_st.name);

        return 0;
}