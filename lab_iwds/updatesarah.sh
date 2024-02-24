#!/bin/bash

for f in `ls ./ldif/update_3*`
do
	echo $f
	ldapmodify -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done
