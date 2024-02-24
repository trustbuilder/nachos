#!/bin/bash

for f in `ls ./ldif/add_0*`
do
	echo $f
	ldapadd -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done

for f in `ls ./ldif/add_2*`
do
	echo $f
	ldapmodify -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done

for f in `ls ./ldif/add_1*`
do
	echo $f
	ldapadd -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done

for f in `ls ./ldif/update_3*`
do
	echo $f
	ldapmodify -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done
