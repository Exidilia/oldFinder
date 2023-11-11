#!/bin/bash

# 0.clone targets from web regularly:
#    https://github.com/arkadiyt/bounty-targets-data/blob/main/data/wildcards.txt
#         work on this on to get subdomains
#    https://github.com/arkadiyt/bounty-targets-data/blob/main/data/domains.txt
#         this needs to be added to the subdomains and domains from the wildcards.txt


# 1. get as many as targets that you can
cat target_domains.txt | subfinder -silent -o target_sub_domains.txt    

echo scanning the targets with **httpx** and extract the files which has **PHP** technology

httpx -l target_sub_domains.txt -td -nc -silent -o target_with_techs.txt | grep PHP | cut -d " " -f 1 > php_targets.txt


echo scanning the new list of targets with **wayback** then with **katana** to get all the links

cat php_targets.txt | waybackurls > links_wayback.txt
cat php_targets.txt | katana -silent -o links_katana.txt


echo cleanning the output files \& use **anew** to unify the links then extract all **.php** files

cat links_wayback.txt links_katana.txt | anew anew_links.txt
cat anew_links.txt | grep -E '^[^?]*\.php$' > php_file_links.txt


echo appending file_postfixes.txt list to your file names and check the response content with **httpx**.

while read suffix; do
  sed "s/\$/$(echo $suffix | sed 's/\./\\./g')/" php_file_links.txt >> new_links.txt
done < file_suffixes.txt

httpx -l new_links.txt -mc 200,302 -o -fs 404 output.txt #-ms "<?php"
cat output.txt
