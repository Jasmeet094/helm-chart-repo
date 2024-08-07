#!/bin/bash
#
#    Copyright (C) 2012 Rodolphe Quiédeville <rq@quiedeville.org>
#    Copyright (C) 2012 Loic Dachary <loic@dachary.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
set -e
: ${LOGS:=/var/log/syslog}
: ${TMPFILE:=$(mktemp)}
: ${LOGFILE:=/tmp/nagios_oom_killer}

function run() {
    local out='OK : OOM everything is fine'
    local length=$(sudo grep -h 'Out of memory' $LOGS | tee $LOGFILE | wc -l)

    if [[ $length -gt 0 ]]; then
        echo "Critical: `cat $LOGFILE`"
        return 2
    fi

    echo $out
    return 0
}

if [ "$1" = TEST ] ; then
    set -x
    set -o functrace
    PS4=' ${FUNCNAME[0]}: $LINENO: '

    LOGS=$(mktemp)
    LOGFILE=$(mktemp --dry-run)
    TIMEFILE=$(mktemp --dry-run)

    function test_run() {
        out="$(run)"
        if [ -z "$out" ] || ! expr "$out" : '^OK'  ; then
            echo 'expected successfull run indicating that no out of memory is detected'
            return 1
        fi

        echo 'Dec 10 18:19:01 pavot kernel: [291484.458704] Out of memory: kill process dovecot(5657:#17) score 46580 or a child' > $LOGS

        if run ; then
            echo 'expected exit code 2 : indicating that an out of memory is detected'
            return 2
        fi

        sleep 1

        rm $LOGFILE

        out="$(run)"
        if [ -z "$out" ] || ! expr "$out" : '^OK'  ; then
            echo 'expected successfull run indicating that out of memory has been fixed'
            return 3
        fi
    }

    test_run

    rm -f $LOGS $LOGFILE $TIMEFILE

elif [ "$1" = "-h" -o "$1" = "--help" ] ; then
    cat <<EOF
Usage: check_oom_killer [--help] [-h]

Look for the 'Out of memory' string in the /var/log/kern.log file. Its
presence indicates the OOM Killer was activated.  For more
information: http://en.wikipedia.org/wiki/Out_of_memory

When an 'Out of memory' is found, the line is stored permanently in
the file $LOGFILE. The file must be removed manually when the problem
is fixed so that check_oom_killer returns OK again.

EOF
else
    run "$@"
fi

# Interpreted by emacs
# Local Variables:
# compile-command: "bash check_oom_killer TEST"
# End: