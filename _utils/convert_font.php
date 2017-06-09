<?
//header('Content-Type: image/png');
$f = file_get_contents('CHOPDUEL.003');
$im = imagecreatetruecolor((8+1)*256, 8);
$white = imagecolorallocate($im, 255, 255, 255);
$black = imagecolorallocate($im, 0, 0, 0);
$div = imagecolorallocate($im, 0, 255, 0);
imagecolortransparent($im, $black);

for($c=0; $c<256; $c++) {
	$char = substr($f, $c*8, 8);
	imageline($im, $c*(8+1), 0, $c*(8+1), 7, $div);
	for($x=0; $x<8; $x++) {
		for($y=0; $y<8; $y++) {
			$b = str_pad(base_convert(ord($char[$y]), 10, 2), 8, "0", STR_PAD_LEFT);
			$color = ($b[$x] == '1') ? $white : $black;
			imagesetpixel($im, $c*(8+1)+$x+1, $y, $color);
		}
	}
}
imagepng($im, 'font.png');
//imagepng($im);
