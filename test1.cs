<?cs if:Query.myselect.0 ?>
      myselect =
      <?cs set:first = #1 ?>
      <?cs each:myselect = Query.myselect ?>
	 <?cs if:#first ?><?cs set:first = #0 ?><?cs else ?>, <?cs /if ?>
	 <?cs var:myselect ?>
      <?cs /each ?>
    <?cs else ?>
	myselect = <?cs var:Query.myselect ?>
    <?cs /if ?>c