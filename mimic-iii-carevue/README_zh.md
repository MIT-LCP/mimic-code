# MIMIC-III CareVue数据库全平台通用（MAC OS、Windows、Linux）一键安装脚本

[README](README.md) | [中文文档](README_zh.md)

## 1 关于此脚本

一键式安装MIMIC-III CareVue数据库。无论什么操作系统(MAC OS、Windows、Linux)，以最快、最方便的方式完成MIMIC-III CareVue数据库及相关Concepts的安装。此重症数据库系列安装脚本可节省你大量时间。

## 2 安装前需要核对

### 2.1 Windows用户请安装[Git软件](https://git-scm.com/download/win)（仅Windows用户必须）

本脚本中需要使用`sed`命令**配置pg_hba.conf**（使用`sed`命令重置数据库的本地连接模式为`trust`，以便后期使用shell脚本自动静默安装数据库）。MAC OS终端默认`sed`版本为`FreeBSD`（当然你也可以使用`Homebrew`安装`GNU版本sed`，即`gsed`，非必须选项），此脚本可自动识别MAC OS终端`sed`版本并执行相应的命令。大多数Linux发行版以及Windows下[Git软件](https://git-scm.com/download/win)中内置的`sed`版本为`gsed`。由于Windows系统中`Command Prompt`没有`sed`命令且**无法运行shell脚本**，所以我们需要借用`Git终端`以确保脚本可以自动运行。

#### ① 安装[Git软件](https://git-scm.com/download/win)后，双击 `BashHere.reg` 以创建 `bash`终端快捷键。

下载最新版本的Git，然后使用默认设置进行安装（**确保安装到`C:\Program Files\Git`目录下**）。由于脚本中会使用到Unix的管道符的重定向进行操作，而Git软件默认的`Git bash here`会导致管道符传参失败，故我们使用`C:\Program Files\Git\bin`目录下的`bash.exe`作为终端确保脚本的顺利运行。接下来在`code`子文件夹中双击`BashHere.reg`添加`bash终端`的快捷键至鼠标右键。
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/02.png" width="90%" height="90%" />
</p>

#### ② 右键打开 `bash`终端。

在`mimic-iii-carevue文件夹`单击鼠标右键，选择`Bash Here`，即可打开支持管道符重定向的`bash终端`。
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/03.png" width="90%" height="90%" />
</p>

### 2.2 确保Postgresql安装且环境变量已经配置（必须）

打开 `终端`（ **Windows用户单击鼠标右键，选择`Bash Here`**，使用2.1中提到的**`bash终端`**） ，输入以下代码，如返回一串具体的安装路径则证明`Postgresql环境变量`设置正常。

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

### 2.3 操作系统用户名及数据库用户名（必须）

#### ① 确保操作系统用户名不要含有汉字、空格等特殊字符

为方便日后数据库安装及维护，脚本会一键式设置与操作系统用户名同名的数据库用户及数据库，此后在终端可直接使用`psql`命令而无需附带任何用户名及数据库参数（即`-U`和`-d`）。因此脚本首先会判断操作系统用户名是否含有空格、汉字、日文、韩文等特殊字符，如符合上述条件，则安装将会自动终止，除非在操作系统下新建一个符合规范（尽量使用`英文字母`、`数字`以及`_`等字符任意组合）的用户名并以此登录。
#### ② 确保默认的数据库用户`postgres`可用
一般来说使用默认设置安装Postgresql之后，数据库会存在一个名为`postgres`的管理员用户。在这个一键安装脚本中会使用`终端`和`psql`命令进行一些操作，因此请确保`postgres管理员用户`的状态为可用。一般来说，无论在MAC OS、Windows或者Ubuntu，只要未修改默认设置，`postgres管理员用户`的状态都是可用的。在终端中输入以下命令即可检测`postgres管理员用户`是否存在（以MAC OS为例），当终端出现以`postgres`为开头的信息即表示可用。

```shell
psql -U postgres;
```
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/07.png" width="90%" height="90%" />
</p>


## 3 数据库一键安装

### 3.1 数据库文件加载路径

完成上述工作后，将`MIMIC3-Carevue-V1.4`数据库文件**解压后**放在**database文件夹**（以MAC OS为例）。
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/08.png" width="90%" height="90%" />
</p>
### 3.2 一键安装

在shell脚本文件路径下进入终端（对于Windows用户需要单击鼠标右键，选择`git bash here`，即可打开`Git终端`），输入并运行如下命令，选择相应的选项后即可完成数据库的自动安装。

```shell
bash install.sh
```
- 一键安装
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/09.png" width="90%" height="90%" />
</p>

- 安装基础表单
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/10.png" width="90%" height="90%" />
</p>

- 安装基础表单
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/11.png" width="90%" height="90%" />
</p>

- 安装concepts
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/12.png" width="90%" height="90%" />
</p>

- 数据核对
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/13.png" width="90%" height="90%" />
</p>

- 数据核对
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/14.png" width="90%" height="90%" />
</p>

- Dbeaver展示
<p align="center">
  <img src="https://raw.githubusercontent.com/ningyile/mimic-code/main/mimic-iii-carevue/img/15.png" width="90%" height="90%" />
</p>

## 4 附言

* [MIMIC-III Clinical Database CareVue subset official website](https://physionet.org/content/mimic3-carevue/1.4/)
* 相关问题请参考：[Are there duplications between patients in CareVue part of MIMIC III and patients in MIMIC IV ?](https://github.com/MIT-LCP/mimic-code/issues/1331)
* 安装代码修改自[MIMICIII-V1.4的sql代码](https://github.com/ningyile/mimic-code/tree/main/mimic-iii)，移除了其中关于MetaVision（MV）相关数据源的安装代码（包括[echo_data.sql](https://github.com/ningyile/mimic-code/blob/main/mimic-iii/concepts/echo_data.sql)）。
* Concepts中增加了Sepsis3标准，其sql代码修改自[A Comparative Analysis of Sepsis Identification Methods in an Electronic Database](https://www.ncbi.nlm.nih.gov/pubmed/29303796)。[sepsis3-mimic](https://github.com/alistairewj/sepsis3-mimic) 由[Alistair Johnson](https://github.com/alistairewj)创立。
* Concepts中增加了Charlson评分，其sql代码修改自[MIMICIV的Concepts中Charlson评分代码](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iv/concepts_postgres/comorbidity/charlson.sql)。
* 如果您想添加一个新特性，请先创建一个问题来描述新特性。
* 水平有限，欢迎对该文档进行改进，即使是一些拼写错误也可以。
* 安装出现任何问题，欢迎通过ningyile@qq.com或者微信（`ningyile`）、推特（`ningyile`）联系（请备注来意）。
