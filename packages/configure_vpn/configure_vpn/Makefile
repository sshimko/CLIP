prefix=$(DESTDIR)
bindir=$(prefix)/usr/bin
initdir=$(prefix)/etc/init\.d/
unitdir=$(prefix)/etc/systemd/system/

all: add_vpn_user

UNIT_FILES=configure-vpn.service
INIT_SCRIPTS=configure-vpn
HELPER_PROGS=add_vpn_user.sh gen_word.sh vpn_login.py vpn_funcs.sh

#TODO more hardened flags?
CFLAGS := -Werror -Wextra -Wall

add_vpn_user: add_vpn_user.c
	$(CC) $(CFLAGS) -o $@ $^

install: add_vpn_user $(HELPER_PROGS) $(INIT_SCRIPTS)
	mkdir -p $(bindir)
	mkdir -p $(initdir)
	mkdir -p $(unitdir)
	install -m 4755 add_vpn_user $(bindir)
	install -m 755 $(HELPER_PROGS) $(bindir)
	install -m 755 $(INIT_SCRIPTS) $(initdir)
	install -m 644 $(UNIT_FILES) $(unitdir)

clean:
	$(RM)  -r add_vpn_user

.PHONY: install
