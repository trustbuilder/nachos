#!/bin/bash

for f in `ls ./ldif/add_1*`
do
	echo $f
	ldapadd -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -f $f
done
