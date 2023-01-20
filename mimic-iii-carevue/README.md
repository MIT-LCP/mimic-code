# One-Click Installation Universal Script for MIMIC-III Clinical Database CareVue subset on MAC OS, Windows, and Linux

[README](README.md) | [中文文档](README_zh.md)

## 1 About this script

A one-click installation universal script for MIMIC-III Clinical Database CareVue subset, no matter what operating system(MAC OS, Windows, and Linux), you can complete the installation of MIMIC-III Carevue database and related concepts in the fastest and most convenient way. A life-saving series tool for installation of critical care database.

## 2 Before installation

### 2.1 Install [Git](https://git-scm.com/download/win) (only for Windows user)

In this script, `sed` would be used to configure **pg_hba.conf** (Reset the mode of local connection as `trust` with `sed` , for automatically and silently installation of the database with the shell script later). Mac OS terminals have ` sed`of `FreeBSD version` built in by default (of course you can also use `Homebrew` to install the `sed` of `GNU version` , namely `gsed`, not required), this script automatically recognizes the version of `sed` in MAC OS and executes the corresponding commands. The `sed` built in Linux distributions and [Git software](https://git-scm.com/download/win) for Windows is `gsed`. Since the shell scripts cannot be executed with `Command Prompt` on Windows (also unable to excute `sed` command), we would run shell scripts in `Terminal` provided by `Git`. 

#### ① After installation of [Git](https://git-scm.com/download/win), double click `BashHere.reg` to create shortcut of `bash Terminal`.

Download the latest version of Git and install it with the default settings(**Install Git in `C:\Program Files\Git`**). Because the script will utilize the pipe operator for redirection, and terminal provided by `Git bash here` will cause the parameter passing failure of pipe operator, so we use the terminal provided by `bash.exe` in `C:\Program Files\Git\bin` to ensure successful execution of script. Next we would create shortcut of `bash Terminal ` to the right mouse menu by double-clicking `BashHere.reg` in the `code` subfolder.

<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/02.png" width="90%" height="90%" />
</p>

#### ② Open the `bash Terminal`.

Right-click in the `mimic-iii-carevue` folder and select `Bash Here` to open `bash Terminal`, which supports piping and redirection.

<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/03.png" width="90%" height="90%" />
</p>

### 2.2 Ensure Postgresql was installed and `psql` bin directory path was added to the environment variable (required)

Open the `Terminal`(For Windows user, Right-click in the `mimic-iii-carevue` folder and select `Bash Here` to open `bash Terminal`, which mentioned in section 2.1). The environment variable was set correctly if a specific installation path (Postgresql ) is returned after type the following command in the `Terminal`.

```shell
which psql
```
- On Windows 10
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/04.png" width="90%" height="90%" />
</p>

- On Ubuntu
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/05.png" width="90%" height="90%" />
</p>

- On MAC OS
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/06.png" width="90%" height="90%" />
</p>

### 2.3 Operating System User Name and Database User name (required)

#### ① Ensure operating system user name does not contain any special characters and Spaces

In order to facilitate the installation and maintenance of the database, the shell script will create the database user and database with the same name as the operating system user name. Then the `psql` command can be used directly in the terminal without any user name and database parameters (namely `-U` and `-d`). Therefore, the script first checks whether the operating system user name contains any special characters, such as Spaces, Chinese alphabets, Japanese alphabets, korean alphabets and so on. If the user name meet the preceding conditions, the installation will be automatically terminated unless creating a new user name that meets the conditions  (preferably any combination of `English alphabets`, `numbers`, and`_`) and log in.

#### ② Ensure the default database user name `postgres` is available
After installing Postgresql with the default setting, the database will have an administrator user named `postgres`. The `psql` commands would be used in this one-click installation script, so make sure that the status of the  database user `postgres` is available. Generally speaking, whether on MAC OS, Windows, or Ubuntu, the `postgres` administrator user status is available as long as the default settings were not changed. Run the following command in the terminal to check whether the `postgres`administrator user exists. If the terminal displays a message starting with `postgres`, it indicates that the `postgres` is available (The following figure for MAC OS as an example).

```shell
psql -U postgres;
```
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/07.png" width="90%" height="90%" />
</p>


## 3 Installation of MIMIC-III CareVue

### 3.1 Load path of database files

Decompress the `mimic-iii-clinical-database-carevue-subset-1.4.zip` database file and then move to the **database folder** (The following figure for MAC OS as an example).

<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/08.png" width="90%" height="90%" />
</p>
### 3.2 One click installation in the `Terminal`

Open the the `Terminal` (for Windows users, you need to right-click the mouse and choose `git bash here` to open the `Terminal` provided by `Git`) and enter **the path of install shell script**, type and run the following command, and select the corresponding option to complete the automatic installation of the MIMIC-III CareVue database.

```shell
bash install.sh
```
- Install database with one command
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/09.png" width="90%" height="90%" />
</p>

- Install basic tables
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/10.png" width="90%" height="90%" />
</p>

- Install basic tables
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/11.png" width="90%" height="90%" />
</p>

- Install concepts
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/12.png" width="90%" height="90%" />
</p>

- Check data
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/13.png" width="90%" height="90%" />
</p>

- Check data
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/14.png" width="90%" height="90%" />
</p>

- DBeaver
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/15.png" width="90%" height="90%" />
</p>

## 4 P.S.

* [MIMIC-III Clinical Database CareVue subset official website](https://physionet.org/content/mimic3-carevue/1.4/)
* Related issue: [Are there duplications between patients in CareVue part of MIMIC III and patients in MIMIC IV ?](https://github.com/MIT-LCP/mimic-code/issues/1331)
* SQL codes were edited based on the the base of [MIMICIII-V1.4](https://github.com/ningyile/mimic-code/tree/main/mimic-iii). Code blocks related to MetaVision (MV) were removed (including [echo_data.sql](https://github.com/ningyile/mimic-code/blob/main/mimic-iii/concepts/echo_data.sql)).
* Sepsis3 has been added to the Concepts, which was edited based on [A Comparative Analysis of Sepsis Identification Methods in an Electronic Database](https://www.ncbi.nlm.nih.gov/pubmed/29303796). [sepsis3-mimic](https://github.com/alistairewj/sepsis3-mimic) created by[Alistair Johnson](https://github.com/alistairewj)。
* Charlson Comorbidity Index has been added to the Concepts, which was edited based on[Charlson in Concepts of MIMICIV](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iv/concepts_postgres/comorbidity/charlson.sql)。
* If you want to add a new feature, please create an issue first to describe the new feature.
* Sorry for my poor English. Improvements for this document are welcome, even some typo fixes. 
