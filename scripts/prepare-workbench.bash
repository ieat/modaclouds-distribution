#!/dev/null

if ! test "${#}" -eq 0 ; then
	echo "[ee] invalid arguments; aborting!" >&2
	exit 1
fi

if test ! -e "${_tools}" ; then
	mkdir "${_tools}"
	mkdir "${_tools}/bin"
	mkdir "${_tools}/lib"
	mkdir "${_tools}/pkg"
fi

case "${_distribution_local_os}" in
	
	( mos::* )
		
		. "${_scripts}/prepare-workbench-env-mos.bash"
		
		if test -e "${_tools}/.os-prepared" ; then break ; fi
		
		tazpkg recharge
		tazpkg upgrade <<<y
		
		for _dependency in "${_distribution_mos_dependencies[@]}" ; do
			tazpkg get-install "${_dependency}"
		done
		
		if test ! -e "${_tools}/pkg/erlang" -o ! -l "${_tools}/pkg/erlang" ; then
			ln -s -T -- /opt/mosaic-erlang-r15b01/lib/erlang "${_tools}/pkg/erlang"
		fi
		
		if test ! -e "${_tools}/bin/python2" -o ! -l "${_tools}/bin/python2" ; then
			ln -s -T -- /usr/bin/python2.7 "${_tools}/bin/python2"
		fi
		
		touch "${_tools}/.os-prepared"
	;;
	
	( ubuntu::12.04 )
		
		. "${_scripts}/prepare-workbench-env-ubuntu.bash"
		
		if test -e "${_tools}/.os-prepared" ; then break ; fi
		
		apt-get update -y
		yes | apt-get upgrade -y
		
		for _dependency in "${_distribution_ubuntu_dependencies[@]}" ; do
			yes | apt-get install -y "${_dependency}"
		done
		
		if test ! -e "${_tools}/pkg/erlang" -o ! -l "${_tools}/pkg/erlang" ; then
			ln -s -T -- /usr/lib/erlang "${_tools}/pkg/erlang"
		fi
		
		if test ! -e "${_tools}/bin/python2" -o ! -l "${_tools}/bin/python2" ; then
			ln -s -T -- /usr/bin/python2.7 "${_tools}/bin/python2"
		fi
		
		touch "${_tools}/.os-prepared"
	;;
	
	( unknown::* | archlinux::* )
		echo "[ww] unknown local OS \`${_distribution_local_os}\`; proceeding!" >&2
	;;
	
	( * )
		echo "[ee] invalid local OS \`${_distribution_local_os}\`; aborting!" >&2
		exit 1
	;;
esac

"${_git_bin}" submodule update --quiet --init --recursive
"${_git_bin}" submodule foreach --quiet --recursive 'chmod -R +w . && git reset -q --hard HEAD && git clean -q -f -d -x'

if test ! -e "${_repositories}/mosaic-java-platform/.lib" ; then
	ln -s -T -- "${_tools}/lib" "${_repositories}/mosaic-java-platform/.lib"
fi

if test ! -e "${_repositories}/mosaic-examples-realtime-feeds/.lib" ; then
	ln -s -T -- "${_tools}/lib" "${_repositories}/mosaic-examples-realtime-feeds/.lib"
fi

exit 0
