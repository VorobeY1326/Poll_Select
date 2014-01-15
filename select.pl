use IO::Select;
use IO::Socket;

$lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 11011);
$sel = IO::Select->new( $lsn );

while(@ready = $sel->can_read) {
	foreach $fh (@ready) {
		if($fh == $lsn) {
			# Create a new socket
			$new = $lsn->accept();
			$sel->add($new);
			print "Peer connected!\r\n";
		}
		else {
			# Process socket
			my $data;
			$fh->recv($data,256,0);
			if ($data ne '')
			{
				# Answer him
				$fh->print($data);
				$fh->flush();
				print "Asked/answered: '" . $data . "'\r\n";
			}
			else
			{
				# We have finished with the socket
				$sel->remove($fh);
				$fh->close();
				print "Peer disconnected..\r\n";
			}
		}
	}
}