# SVG element
svg = d3.select('svg')
polygon = svg.selectAll('polygon')

# Height and width from window
height = window.innerHeight
width = window.innerWidth

# Height and width from svg
svgHeight = svg.attr('height')
svgWidth = svg.attr('width')

# Countries where we have some datas
countries = ['Espagne', 'France', 'Italie', 'Grèce', 'Allemagne', 'Belgique', 'Royaume-Uni', 'Irlande', 'Suède', 'Finlande', 'Norvège']

# Phrases
tipSelectOne   = 'Sélectionnez un des pays en couleur afin de découvrir quel est son modèle éducatif !'
tipSelectTwo   = 'Sélectionnez un deuxième pays afin de comparer ses données au premier !'
tipSelectOther = 'Cliquez sur un autre pays pour changer votre deuxième sélection ou réinitialisez pour recommencer.'

# Colors
active = '#f5b355'
inactive = '#f8f8f8'
hover = '#06A59B'

# Update window 
updateWindow = () ->
	temp = (svgHeight - height)/2 +60
	svg.attr('viewBox', '0 '+temp+' '+svgWidth+' '+svgHeight)

# Update window when resizing window (broswer)
window.onresize = () ->
	updateWindow()
updateWindow()

# Map
map = 
	init: () ->
		# Set map to default
		polygon.each () ->
			d3.select(this).classed 'selected', false
			d3.select(this).classed 'second-selection', false
			d3.select(this).attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive

		d3.selectAll('#infos h2').text('')
		d3.selectAll('#infos span').style('display', 'none')

		d3.select('#tip').text(tipSelectOne)

	changePointer: () ->
		# Pointer on available countries
		polygon.each () ->
			if d3.select(this).attr('fill') != inactive then d3.select(this).style('cursor', 'pointer')

	onMouseOver: () ->
		# Fill with another color on hover
		map.changePointer()
		el      = d3.select(this)
		country = el.attr 'data-pays'

		polygon.each () ->
			if el.attr('fill') != inactive && d3.select(this).attr('data-pays') == country || d3.select(this).classed('selected') == true then d3.select(this).attr('fill', hover)
	
	onMouseLeave: () ->
		# Reset default background color on mouse leave country
		polygon.each () ->
			if d3.select(this).attr('fill') != inactive && d3.select(this).classed('selected') == false then d3.select(this).attr('fill', active)

	onClick: () ->
		el      = d3.select(this)
		country = el.attr('data-pays')
		counter = 0

		tempArray = []
		counts = []

		polygon.each () ->
			if d3.select(this).classed('selected') is true
				tempArray.push d3.select(this).attr('data-pays')

		# pour chaque valeur dans tempArray, je vérifie si elle est dans counts
		# Si elle y est : je passe à la suivante
		# si elle n'y est pas, je l'ajoute dans counts.
		for i in tempArray
			if counts.indexOf(i) is -1 then counts.push(i)

		counter = counts.length

		console.log el.attr('fill')

		if el.attr('fill') == hover
			switch counter
				# No one was clicked
				when 0 
					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed('selected', true)
								.attr('fill', hover)

					d3.select('.country').text(country)
					d3.select('#tip').text(tipSelectTwo)

					
				# One country is selected so we can add a second one
				when 1 
					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed('selected second-selection', true)
								.attr('fill', hover)

					textCountry = d3.select('.country').text()
					d3.select('.country').text(textCountry+' et '+el.attr('data-pays'))
					d3.select('.reset-map').style('display', 'inline-block')

					d3.select('#tip').text(tipSelectOther)


				# Two countries are selected, we have to remove the last one and select the new one
				when 2
					polygon.each () ->
						if d3.select(this).classed('second-selection') is true
							d3.select(this).classed('selected second-selection', false)
							d3.select(this).attr('fill', active)

					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed('selected second-selection', true)
								.attr('fill', hover)

					textCountry = d3.select('.country').text()
					textCountry = textCountry.split(' ')
					d3.select('.country').text(textCountry[0]+' et '+el.attr('data-pays'))
					d3.select('.reset-map').style('display', 'inline-block')

			d3.select('.more-info').style('display', 'inline-block').attr('data-pays', country)

d3.select('.reset-map').on 'click', map.init

polygon
	# Change color on mouseover
	.on 'mouseover', map.onMouseOver
	.on 'mouseleave', map.onMouseLeave
	.on 'click', map.onClick
	# Fill countries (depends of if we have datas)
	.each () ->
		d3.select this
			.attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive
