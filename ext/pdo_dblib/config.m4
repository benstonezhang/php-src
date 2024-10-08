PHP_ARG_WITH([pdo-dblib],
  [for PDO_DBLIB support via FreeTDS],
  [AS_HELP_STRING([[--with-pdo-dblib[=DIR]]],
    [PDO: DBLIB-DB support. DIR is the FreeTDS home directory])])

if test "$PHP_PDO_DBLIB" != "no"; then
  if test "$PHP_PDO_DBLIB" = "yes"; then
    dnl FreeTDS must be on the default system include/library path.
    dnl Only perform a sanity check that this is really the case.
    PHP_CHECK_LIBRARY([sybdb], [dbsqlexec],
      [],
      [AC_MSG_FAILURE([Cannot find FreeTDS in known installation directories.])])
    PHP_ADD_LIBRARY([sybdb],, [PDO_DBLIB_SHARED_LIBADD])
  elif test "$PHP_PDO_DBLIB" != "no"; then
    if test -f $PHP_PDO_DBLIB/include/sybdb.h; then
      PDO_FREETDS_INSTALLATION_DIR=$PHP_PDO_DBLIB
      PDO_FREETDS_INCLUDE_DIR=$PHP_PDO_DBLIB/include
    elif test -f $PHP_PDO_DBLIB/include/freetds/sybdb.h; then
      PDO_FREETDS_INSTALLATION_DIR=$PHP_PDO_DBLIB
      PDO_FREETDS_INCLUDE_DIR=$PHP_PDO_DBLIB/include/freetds
    else
      AC_MSG_ERROR([Directory $PHP_PDO_DBLIB is not a FreeTDS installation directory])
    fi

    AS_VAR_IF([PHP_LIBDIR],, [PHP_LIBDIR=lib])

    if test ! -r "$PDO_FREETDS_INSTALLATION_DIR/$PHP_LIBDIR/libsybdb.a" && test ! -r "$PDO_FREETDS_INSTALLATION_DIR/$PHP_LIBDIR/libsybdb.so"; then
       AC_MSG_ERROR([[Could not find $PDO_FREETDS_INSTALLATION_DIR/$PHP_LIBDIR/libsybdb.[a|so]]])
    fi

    PHP_ADD_INCLUDE([$PDO_FREETDS_INCLUDE_DIR])
    PHP_ADD_LIBRARY_WITH_PATH([sybdb],
      [$PDO_FREETDS_INSTALLATION_DIR/$PHP_LIBDIR],
      [PDO_DBLIB_SHARED_LIBADD])
  fi

  PHP_CHECK_PDO_INCLUDES

  PDO_DBLIB_DEFS="-DPDO_DBLIB_FLAVOUR=\\\"freetds\\\""
  PHP_NEW_EXTENSION([pdo_dblib],
    [pdo_dblib.c dblib_driver.c dblib_stmt.c],
    [$ext_shared],,
    [$PDO_DBLIB_DEFS -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1])
  PHP_SUBST([PDO_DBLIB_SHARED_LIBADD])

  PHP_ADD_EXTENSION_DEP(pdo_dblib, pdo)
fi
