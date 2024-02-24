#!/bin/bash

ldapdelete -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
 "cn=Sarah Frechi,ou=people,dc=planetexpress,dc=com"
ldapdelete -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
 "cn=Sarah de Laconta,ou=people,dc=planetexpress,dc=com"
ldapdelete -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
 "cn=Robert de Laconta,ou=people,dc=planetexpress,dc=com"
ldapdelete -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
 "cn=inWebo Users,ou=people,dc=planetexpress,dc=com"


