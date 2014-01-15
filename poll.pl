use IO::Poll;
use IO::Socket;

$lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 11011);
$poll = IO::Poll->new();

$poll->mask($lsn => POLLIN);

while(1) {
	$poll->poll();
	foreach $fh ($poll->handles(POLLIN)) {
		if($fh == $lsn) {
			# Create a new socket
			$new = $lsn->accept();
			$poll->mask($new => POLLIN);
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
				$poll->mask($fh => 0);
				$fh->close();
				print "Peer disconnected..\r\n";
			}
		}
	}
}
