prefix=$(DESTDIR)
bindir=$(prefix)/usr/bin
initdir=$(prefix)/etc/init\.d/

all: add_vpn_user

INIT_SCRIPTS=configure-vpn
HELPER_PROGS=add_vpn_user.sh gen_word.sh vpn_login.py vpn_funcs.sh

#TODO more hardened flags?
CFLAGS := -Werror -Wextra -Wall

add_vpn_user: add_vpn_user.c
	$(CC) $(CFLAGS) -o $@ $^

install: add_vpn_user $(HELPER_PROGS) $(INIT_SCRIPTS)
	mkdir -p $(bindir)
	mkdir -p $(initdir)
	install -m 4755 add_vpn_user $(bindir)
	install -m 755 $(HELPER_PROGS) $(bindir)
	install -m 755 $(INIT_SCRIPTS) $(initdir)

clean:
	$(RM)  -r add_vpn_user

.PHONY: install
