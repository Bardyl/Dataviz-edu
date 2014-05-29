$('header a').on('click', function(e) {
	e.preventDefault();

	$(this).toggleClass('open');

	if($(this).hasClass('open')){
		$('#content').animate({
			'right': '25%'
		});
	} else {
		$('#content').animate({
			'right': '0'
		});		
	}
});