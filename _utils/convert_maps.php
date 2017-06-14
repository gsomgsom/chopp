<?
$f = file_get_contents('CHOPDUEL.004');

for ($l=0; $l<50; $l++) {
	$level_code = "-- level ".($l+1)."\nreturn {\n\tdata = {";
	for ($y=0; $y<12; $y++) {
		$level_code .= "\n\t\t";
		for ($x=0; $x<20; $x++) {
			$level_code .= str_pad(ord($f[$l*12*20 + $y*20 + $x]), 3, " ", STR_PAD_LEFT);
			if (($x<20) && ($y<12)) {
				$level_code .= ', ';
			}
		}
	}
	$level_code .= "\n\t}\n}\n";
	file_put_contents('level_'.($l+1).'.lua', $level_code);
}
