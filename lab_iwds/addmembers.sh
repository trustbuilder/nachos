#!/bin/bash

for f in `ls ./ldif/add_2*`
do
	echo $f
	ldapmodify -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done
