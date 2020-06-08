#!/bin/bash
date=$(date +"%H:%M:%S")
ip_eth=$(ip a show eth0 | awk '/inet /{print $2}' | cut -d '/' -f1 | head -n1)
ip_wifi=$(ip a show wlan0 | awk '/inet /{print $2}' | cut -d '/' -f1 | head -n1)
bg_img="bg.jpg"
info_char=60
fsize_song=2
linelen=21
maxlen=30

playtime=$(mpc | grep playing | awk '{print $3}')
status=$(volumio status)
for i in volume title artist album samplerate bitdepth mute random trackType repeat
do
	value=$(echo "$status" | grep "\"$i\"" | tr -s ' ' | cut -d' ' -f3- | tr -d '",' | cut -c -$info_char)
        eval $i=\$value
done
albumart=$(echo "$status" | grep '"albumart"' | tr -s ' ' | cut -d' ' -f3- | tr -d '",')
echo "${albumart}" | egrep -q '^http' || albumart=http://localhost:3000$albumart
for i in title artist album
do
        eval varlen=\$\{\#$i\}
        [ $varlen -gt $linelen ] &&  {
                fsize_song=1
        }
done

volume=${volume}%
fcolor_volume="yellow"
[ $mute = true ] && {
	fcolor_volume="red"
	volume=MUTE
}

if [ $random = true ] ; then
	random_img="images/random.png"
else
	random_img="images/norandom.png"
fi

if [ $repeat = true ] ; then
	repeat_img="images/repeat.png"
else
	repeat_img="images/norepeat.png"
fi

# <body style="background-color:black;" background="${albumart:-images/$bg_img}">
cat << END
<style type="text/css">
html { overflow-y: hidden; }
body {
    overflow: hidden;
    color: #FFF00F;
    text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
    background-image: url("images/$bg_img");
    background-attachment: fixed
    background-repeat: no-repeat;
    background-position: center center;
}
tbody {
    overflow: hidden;
}
table {
    table-layout: fixed;
    word-wrap: break-word;
}
</style>

<html>
 <head>
  <title>MPD Info</title>
 </head>
 <body style="background-color:black;" >

<table width=280 height=20 border=0>
	<tr>
		<td><font color=#882ee88>
			${trackType:-unknown}&nbsp;-&nbsp;${samplerate:- }&nbsp;-&nbsp;${bitdepth:-}
		</font></td>
		<td width=50 align=right>
			<img src="$random_img"  height=16 width=16/>&nbsp;
			<img src="$repeat_img"  height=16 width=16/>
		</td>
	</tr>
</table>
<table width=300 height=80 border=0>
<tbody style='overflow:none;'>
	<tr>
	    <td width=210> <div style=overflow:hidden;height:100px>
		<font size=+$fsize_song color=#ffaaaa>
		<img src="images/play.png" height=16 width=16>${title:-未知歌曲}<br>
		<img src="images/play.png" height=16 width=16>${artist:-未知歌手}<br>
		<img src="images/play.png" height=16 width=16>${album:-未知專輯}
		</font>
	    </td>
	    <td nowrap width=80 align=right>
		<img src="$albumart" width=80 height=80>
	    </td>
	</tr>
</tbody>
</table>
<table width=310 border=0>
	<tr>
		<td width=33%><center><font color=${fcolor_volume:=yesllow} size=+3>${volume:-0}</font></center></td>
		<td width=67% colspan="2"><center> <font color="white" size=+2>${playtime:=$date}</font> </center></td>
	</tr>
</table>
<table width=314 height=40 border=0>
	<tr>
END
if [ "$ip_eth" ]; then
	cat << END
		<td width=157><img src="images/wired.png" height=22 width=22/><font color=#00FFFF size=2>$ip_eth</font></td>
END
else
	cat << END
		<td width=157><img src="images/nowired.png" height=22 width=22/></td>
END
fi
if [ "$ip_wifi" ]; then
	cat << END
		<td><img src="images/wifi.png" height=18 width=18/><font color=#00FFFF size=2>$ip_wifi</font></td>
END
else
	cat << END
		<td ><img src="images/nowifi.png" height=22 width=22/></td>
END
fi

cat << "END"
	</tr>
</table>
</font>

 </body>
</html>

END


