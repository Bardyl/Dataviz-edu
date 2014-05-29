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
separator      = ' et '

# Colors
active   = '#f5b355'
inactive = '#f8f8f8'
hover    = '#06A59B'

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
			# Removing all class from polygon
			d3.select(this).classed 'selected', false
			d3.select(this).classed 'second-selection', false
			# Reinitialize colors (depend of countries array)
			d3.select(this).attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive

		# Initializing div with informations and buttons
		d3.selectAll('#infos h2').text ''
		d3.selectAll('#infos span').style 'display', 'none'

		# Initialize top head tooltip
		d3.select('#tip').text tipSelectOne

	changePointer: () ->
		# Display a pointer on clickable countries, default on others
		polygon.each () ->
			if d3.select(this).attr('fill') isnt inactive then d3.select(this).style 'cursor', 'pointer'

	onMouseOver: () ->
		# Fill countries with an other color when mouse is on one of them
		map.changePointer()

		# Some vars
		el      = d3.select(this)
		country = el.attr 'data-pays'

		###
		 * Some countries have more than one polygon. So we have to find all polygons with the same data-pays
		 * Conditions needed : 
		 * * Country clickable
		 * * Data-pays is like country we are on hover (or the country has selected class) 
		###
		polygon.each () ->
			if el.attr('fill') isnt inactive and d3.select(this).attr('data-pays') is country or d3.select(this).classed('selected') is true then d3.select(this).attr('fill', hover)
	
	onMouseLeave: () ->
		# Reset default background color on mouse leave country
		polygon.each () ->
			if d3.select(this).attr('fill') isnt inactive and d3.select(this).classed('selected') is false then d3.select(this).attr('fill', active)

	onClick: () ->
		# Actions to trigger on click on a country, we have to consider many cases

		# Some vars
		el      = d3.select(this)
		country = el.attr('data-pays')
		counter = 0

		tempArray = []
		counts = []

		# We have to count all polygons which are selected (count how many have class selected)
		polygon.each () ->
			if d3.select(this).classed('selected') is true
				tempArray.push d3.select(this).attr 'data-pays'

		# For each value in tempArray, we have to check if she is in counts array
		# If she is, we go to next one
		# If not, we have to add them to counts
		# The matter of this is to count how many different countries have the same class
		for i in tempArray
			if counts.indexOf(i) is -1 then counts.push(i)

		# So, definitely, counts.length is the number of element have the « selected » class
		counter = counts.length

		# To prevent from clicking two times on one country and selecting it two times...
		if el.attr('fill') is hover
			# All cases are under these line
			switch counter
				# No one was clicked
				when 0 
					# We add the color on all data-pays of clicked country and add selected class
					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed 'selected', true
								.attr 'fill', hover

					# Updating infos and tool tip
					d3.select('.country').text country
					d3.select('#tip').text tipSelectTwo

				# One country is selected so we can add a second one
				when 1 
					# We add the color on all data-pays of clicked country and add selected class
					# And a second one to remember this is the second country on which we have clicked
					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed('selected second-selection', true)
								.attr('fill', hover)

					# Little concatenation to display the second country
					textCountry = d3.select('.country').text()
					d3.select('.country').text textCountry + separator + el.attr('data-pays')
					
					# Updating infos and tool tip
					d3.select('.reset-map').style 'display', 'inline-block'
					d3.select('#tip').text tipSelectOther

				# Two countries are selected, we have to remove the last one and select the new one
				when 2
					# First, we have to remove all second-selection (the if confition is here cause if we remove them
					# all countries will be painted)
					polygon.each () ->
						if d3.select(this).classed('second-selection') is true
							d3.select(this).classed('selected second-selection', false)
							d3.select(this).attr('fill', active)

					# Now, we can change the selected country (with all little islands (or big))
					polygon.each () ->
						if d3.select(this).attr('data-pays') is el.attr('data-pays')
							d3.select(this)
								.classed('selected second-selection', true)
								.attr('fill', hover)

					# We change the text with a little split to keep only the first country
					textCountry = d3.select('.country').text()
					textCountry = textCountry.split ' '
					d3.select('.country').text textCountry[0]+ separator +el.attr('data-pays')

			# In all cases, we have to display the button to display all datas from one (or to compare) countries
			d3.select('.more-info').style('display', 'inline-block').attr('data-pays', country)

# On click on reset button... we reset...
d3.select('.reset-map').on 'click', map.init

# Action to do on loading page and trigger events
polygon
	.on 'mouseover', map.onMouseOver
	.on 'mouseleave', map.onMouseLeave
	.on 'click', map.onClick
	# Fill countries (depends of if we have datas)
	.each () ->
		d3.select this
			.attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive
