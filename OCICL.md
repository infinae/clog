OCICL is a complete secure alternative to a QuickLisp CLOG install

OCICL loads dependencies with your project. Once setup the command line
tool ocicl is used to prepare a directory for a new project or to convert
and existing project to an ocicl based one. To add dependecies you just
add them to your asd file and will be downloaded as needed. A simple
run of "ocicl latest" updates your project dependecies.

Once installed either in an empty new project dir or existing project do:
(Do not call your project clog, creates asdf circular dependecies.)

```
ocicl setup > init
ocicl install clog
```

Then start to dev with the CLOG Builder:

```
sbcl --userinit init --eval "(asdf:load-system :clog/tools)" --eval "(clog-tools:clog-builder :port 0 :app t)"
```
(or replace ecl for sbcl)

On Windows:

```
sbcl --userinit init --eval "(setf asdf:*compile-file-failure-behaviour* :warn)" --eval "(asdf:load-system :clog/tools)" --eval "(clog-tools:clog-builder :port 0 :app t)"

and after first run can use run-ocicl.bat
```
Note for Windows: unzip https://rabbibotton.github.io/clog/clogframe.zip for
                  needed dlls in directory

I N S T A L L
=============

These are directions for getting started from scratch:

* Step 1 - Install SBCL *

Linux:

Use OS package manager like for example

```
sudo apt-get install sbcl
```

Mac:

On Mac install homebrew from https://brew.sh/

```
brew install sbcl
brew install ocicl
```

For Mac - skip step 2 - you are ready to go!

Windows:

On Windows install Windows AMD 64 from here -
  https://www.sbcl.org/platform-table.html
For example:
   http://prdownloads.sourceforge.net/sbcl/sbcl-2.4.6-x86-64-windows-binary.msi


* Step 2 - Install OCICL *

Create a dir for example projects and cd to it then do:

```
git clone https://github.com/ocicl/ocicl.git
```

the cd in to ocicl and run:

```
sbcl --load setup.lisp
```

Make sure the created ocicl is on your PATH

On Linux:

Close your terminal and reopen and in most distros is, as .local/bin is usually
added if exists.

On Windows:

Permanently make available, by using:

search then type env -> then pick Edit the system environment variables
click the button environment variables -> select Path under User variables
click Edit... -> New and type "%USERPROFILE%\AppData\Local\ocicl\bin\"
"Close the terminal and open a new one


* Step 3 - Create your project directory

Note: ~/common-lisp is always searched so make sure no conflicts in most cases
      you do not want that directory to exist

(If converting a clog project just do in the directory with your .asd file)

For this example using projects/ctest

cd to projects/ctest

```
ocicl setup > init
ocicl install clog
```

Note for Windows: unzip https://rabbibotton.github.io/clog/clogframe.zip for
                  needed dlls in directory. You may also need to add to sbcl
                  --eval "(setf asdf:*compile-file-failure-behaviour* :warn)"
                  
to use sbcl any time in your own ocicl world use:
```
sbcl --userinit init
```

and to start the builder in sbcl:

```
(asdf:load-system :clog/tools)
(clog-tools:clog-builder)
```

If this is the new project a .asd file, first .lisp file and www directory
will be created as well. For windows run-ocicl.bat also created.
