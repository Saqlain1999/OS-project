#!/bin/bash
function read_Desc {
    exec 3<>/dev/tcp/localhost/1234
    while read LINE <&3
    do
        echo $LINE >> $filename.$fileformat
    done
    exec 3<&-
    exec 3>&-
}

echo -e "Welcome To W/e this is"
while true
do
    echo "What would you like to do?"
    echo "Options: "
    echo "1. Get HTML code of any website"
    echo "2. Download Files From The Server"
    echo "3. Get Current Time"
    echo "4. Check Port Availability And Service Running On It"
    echo "5. Check Web Connectivity"
    echo "6. Exit"
    echo "--------------------------------------------------------"
    echo -ne "Select> "
    read option
    if (( $option > 0 && $option < 7 ))
    then
        if (( $option == 1 ))
        then
            htmlFile="htmlCode.txt"
            read -p "Enter the site you want HTML code of: " text
            exec 2<>/dev/tcp/$text/80
            echo -e "GET / HTTP/1.1\r\nhost: $text\r\nConnection: close\r\n\r\n" >&2
            cat <&2 > $htmlFile
            exec 2<&-
            exec 2>&-
            echo "HTML Code retreved in the Database"
            sleep 3
            echo "Setting Up Server To Transfer Data To Your Directory"
            ( python server.py $htmlFile ) &
            sleep 3
            echo "Server UP!"
            echo "Please enter the File Name: "
            read filename
            echo "Would you like to specifiy the Format of this file: "
            echo "(y,Yes/n,No)"
            read option
            fileformat="txt"
            if [[ $option == "y" || $option == "yes" || $option == "Yes" ]]
            then
                echo "Enter File Format (Do not include dot(.) in it): "
                read fileformat
                read_Desc
            else
                read_Desc
            fi
            echo "Data Transfer Completed!, Server Down.."
            echo "File name: $filename, File Format: txt"
        elif (( $option == 2 ))
        then
            listofFiles=$(find . -iname "*" | grep -o ".*" )
            filesArray=(${listofFiles//.\//})
            length=${#filesArray[@]}
            echo "Files Loaded!"
            echo "File List: "
            lengthForCond=$(($length-1))
            for (( i = 1; i < $length; i++ ))
            do
                echo $i") "${filesArray[$i]}
            done
            echo "Select File No, To Download: "
            read fileNo
            if (( $fileNo == 0  || $fileNo > $lengthForCond ))
            then
                while [[ $fileNo == 0 || $fileNo > $lengthForCond ]]
                do
                    echo "Enter a Valid Number"
                    echo "Select File No, To Download: "
                    read fileNo
                    if (( $fileNo != 0  && $fileNo < $lengthForCond ))
                    then
                        break
                    fi
                done
            fi
            ( python server.py ${filesArray[$fileNo]} ) &
            sleep 1
            echo "Transfering."
            sleep 1
            echo "Transfering.."
            sleep 1
            echo "Transfering..."
            exec 3<>/dev/tcp/localhost/1234
            while read LINE <&3
            do
                echo $LINE >> ${filesArray[$fileNo]}"-Copy"
            done
            exec 3<&-
            exec 3>&-
            echo "Data Transfer Completed!, Server Down.."
            echo "File name: ${filesArray[$fileNo]}-Copy"
        elif (( $option == 3 ))
        then
            exec 2<>/dev/tcp/time.nist.gov/13
            cat <&2 > time.txt
            time=$(grep -o '..:..:..' time.txt)
            echo "Standerd UTC Time: "$time
	        rm "time.txt"
        elif (( $option == 4 ))
        then
            echo "Enter the port number you want to check: "
            read portNo
            result=$(timeout 1 cat </dev/tcp/localhost/$portNo)
            echo "Results: "$result
        elif (( $option == 5 ))
        then
            echo "Enter the website which you want to check your connection to: "
            read address
            (echo >/dev/tcp/$address/80) &>/dev/null
            if [ $? -eq 0 ]; then
                echo "Connection successful"
            else
                echo "Connection unsuccessful"
            fi
        elif (( $option == 6 ))
        then
            echo "Thank you for using it"
            exit 1
        fi
    else
        echo "Invalid Input"
    fi
    echo "Would you like to continue? (Y/N)"
    read cont
    if [[ $cont == "N" || $cont == "n"  ]]
    then
        echo "Thank You for Using This"
        break
    fi
done
