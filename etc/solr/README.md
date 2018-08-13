# HHS-Ignite-Shakespeare-Project
HHS Ignite Shakespeare Project

Team Members:
1. Vamsi Krishna Devabathini (vdevabathini3)
2. Amit  Rustagi (arustagi7)
3. Brig Rockwell (brockwell6)
4. Xiaoshan Wang (xwang737)


A short presentation
https://youtu.be/bvBbIT_WOqU 

# Solr

Download solr from here: http://www.apache.org/dyn/closer.lua/lucene/solr/6.2.1 and extract the folder if required.

`cd solr-6.2.1`

To start solr with 2 GB of JVM memory.

`bin/solr start -m 2g`

To create a core 

`bin/solr create_core -c core_name`

Before indexing and after creating the core please replace the solr-config.xml in the core directory created with  solr-config.xml present in this github project inside the solr-config directory. The solr-config.xml is optimised to work with mimicIII dataset.

To index a file(s) (structured or unstructured) to the core with id core_name

`bin/post -c core_name path_to_file(s)`

With these steps completed, you should be able to bring up the solr web UI on http://localhost:8983 on the machine the above instructions are run.

For advanced options please configure the solr-config.xml as described here: https://wiki.apache.org/solr/SolrConfigXml

If your solr instance is running on a cloud server and you do not have browser access, you can use ssh forwarding.
Run the following from your local machine and navigate to http://localhost:8080/ from your local browser.

`ssh -i ~/.ssh/your_cloud_ssh_key -L localhost:8080:127.0.0.1:8983 shared_user@104.154.58.196 -N -C`

The above command would connect to the server team has created for during the project work.
