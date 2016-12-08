# HHS-Ignite-Shakespeare-Project
HHS Ignite Shakespeare Project

Team Members:
1. Vamsi Krishna Devabathini (vdevabathini3)
2. Amit  Rustagi (arustagi7)
3. Brig Rockwell (brockwell6)
4. Xiaoshan Wang (xwang737)


A short presentation
https://youtu.be/bvBbIT_WOqU 


# Django setup


Regular setup with the exception of adding 

        'OPTIONS': {'options': '-c search_path=mimiciii'}
to the DATABASES setting. This takes the place of the following in psql

        SET search_path TO mimiciii;


With this in place we are able to run

        python manage.py inspectdb

and it returns the content of an auto-generated `models.py` file. You may need to make edits to this to leverage django's foreign key relations.

