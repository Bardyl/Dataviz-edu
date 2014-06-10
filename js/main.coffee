# SVG element
svg        = d3.select('#leftContent svg')
polygon    = svg.selectAll('polygon')
filterList = d3.select('#displayData nav')

# Height and width from window
height = window.innerHeight
width = window.innerWidth

# Height and width from svg
svgHeight = svg.attr('height')
svgWidth = svg.attr('width')

# Countries where we have some datas
countries = ['Espagne', 'France', 'Italie', 'Grèce', 'Allemagne', 'Belgique', 'Royaume-Uni', 'Finlande', 'Norvège', 'Luxembourg']

# Phrases
tipSelectOne   = 'Sélectionnez un des pays en couleur afin de découvrir quel est son modèle éducatif !'
tipSelectTwo   = 'Sélectionnez un deuxième pays afin de comparer ses données au premier !'
tipSelectOther = 'Cliquez sur un autre pays pour changer votre deuxième sélection ou réinitialisez pour recommencer.'
separator      = ' et '
modelEducatif  = 'Le modèle éducatif '

# Colors
active   = '#f5b355'
inactive = '#f8f8f8'
hover    = '#06A59B'

# Popup
popupAtStart = true

# Update window 
updateWindow = () ->
	temp = (svgHeight - height)/2 +60
	svg.attr('viewBox', '0 '+temp+' '+svgWidth+' '+svgHeight)

# Update window when resizing window (broswer)
window.onresize = () ->
	updateWindow()
updateWindow()

# Close popup window on click « j'ai compris »
popupAtStart = localStorage.getItem 'blurInfos'

if popupAtStart is null
	d3.select('#blur').classed('closed', false)

d3.select('#blur button')
.on 'click', () ->
	d3.select('#blur').classed('closed', true)
	localStorage.setItem('blurInfos', 'bonjour')

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
		if el.attr('fill') is hover and el.classed('selected') is false
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
					d3.select('.country').text(textCountry[0] + separator + el.attr('data-pays'))

			# In all cases, we have to display the button to display all datas from one (or to compare) countries
			d3.select('.more-info').style('display', 'inline-block').attr('data-pays', country)


graph = 
	init: (filter) ->
		d3.json 'data/filters.json', (root) ->
			if filter == 'noFilter'
				d3.select('#graph-description').html('')
			else
				d3.select('#graph-description').html(root[filter].html)

		d3.selectAll('#datas > div').classed('active', false)
		d3.select('#'+filter).classed('active', true)

		graph.createGraph(filter)

	createGraph: (filter) ->
		el          = d3.select('#'+filter)
		country     = d3.select('#displayData').attr('data-pays')

		switch filter
			when 'coutEtudiant'
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					numbers = data[filter]
					for key in cycles
						d3.select('#coutEtudiant .'+key+' span').text numbers[key]['cout']

			when 'encadrement'
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					data = data[filter]
					for key in cycles
						d3.select('#encadrement .'+key+' .elevesParClass .value').text data[key]['elevesParClass']
						d3.select('#encadrement .'+key+' .elevesParEnseignant .value').text data[key]['elevesParEnseignant']

			when 'rythme'
				d3.selectAll('#rythme .graph-bar .totalStudy').style('width', '0%')
				d3.selectAll('#rythme .graph-bar .totalVacs').style('width', '0%')
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					data = data[filter]
					for key in cycles
						percentageWork = (data[key]['daysByYear'] / data[key]['daysByWeek']) * 100 / 52
						percentageVacs = data[key]['totalVacs'] * 100 / 52

						d3.select('#rythme .'+key+' .graph-bar .totalStudy').transition().duration(1500).style('width', (percentageWork-2)+'%')
						d3.select('#rythme .'+key+' .graph-bar .totalVacs').transition().duration(1500).style('width', (percentageVacs-2)+'%')

						d3.select('#rythme .'+key+' .graph-data .totalStudy').attr('style', 'width:'+(percentageWork-2)+'%')
						d3.select('#rythme .'+key+' .graph-data .totalVacs').attr('style', 'width:'+(percentageVacs-2)+'%')

						d3.select('#rythme .'+key+' .graph-data .totalStudy > span:first-child span').text data[key]['daysByYear']
						d3.select('#rythme .'+key+' .graph-data .totalStudy > span:last-child span').text data[key]['daysByWeek']

						d3.select('#rythme .'+key+' .graph-data .totalVacs > span:first-child span').text data[key]['summerVacs']
						d3.select('#rythme .'+key+' .graph-data .totalVacs > span:last-child span').text data[key]['totalVacs']

			when 'salaire'
				d3.selectAll('#salaire .graph-start').style('width', '0%')
				d3.selectAll('#salaire .graph-end').style('width', '0%')

				salaires = []
				cycles   = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					salaires = data[filter]
					for key in cycles
						salaireStart = salaires[key]['start']
						salaireEnd   = salaires[key]['end']

						d3.select('#salaire .'+key+' .start').text salaireStart
						d3.select('#salaire .'+key+' .preetyName').text salaires[key]['preetyName']
						d3.select('#salaire .'+key+' .end').text salaireEnd

						percentage = salaireStart * 100 / salaireEnd

						d3.select('#salaire .'+key+' .graph-start').transition().duration(1500).style('width', percentage+'%')
						d3.select('#salaire .'+key+' .graph-end').transition().duration(1500).style('width', '100%')
			
			when 'cycle'
				d3.select('#cycle .graph-bar').style('width', '0%')
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					data = data[filter]
					nombreTotalAnnees = []

					for key in cycles
						nombreTotalAnnees.push data[key]['number']
					
					sum = nombreTotalAnnees.reduce (pv, cv) -> pv + cv

					for key in cycles
						nombreAnneesCycles = data[key]['number']
						nombreAnneesOblig  = data[key]['numberOblig']
						heuresParAn        = data[key]['hours']

						d3.select('#cycle .graph-bar').transition().duration(2000).style('width', '100%')

						percentageWidth = nombreAnneesCycles * 100 / sum 
						d3.selectAll('#cycle .'+key).attr('style', 'width:'+(percentageWidth-1)+'%')

						percentageCycleWidth = nombreAnneesOblig * 100 / nombreAnneesCycles
						d3.selectAll('#cycle .'+key+' .nombreAnneesOblig').attr('style', 'width:'+percentageCycleWidth+'%')
						d3.selectAll('#cycle .'+key+' .nombreAnneesNonOblig').attr('style', 'margin-left:'+(percentageCycleWidth)+'%')

						d3.select('#cycle .numbers .'+key+' .nombreAnneesOblig').transition().text nombreAnneesOblig

						if nombreAnneesCycles - nombreAnneesOblig != 0
							d3.select('#cycle .numbers .'+key+' .nombreAnneesNonOblig').text(nombreAnneesCycles - nombreAnneesOblig)

						d3.select('#cycle .cycle .'+key+' span:last-child').text(heuresParAn+'h par an')

			when 'test'
				scores   = []
				matieres = ['maths', 'ecrit', 'science']
				d3.selectAll('#test .graph-bar').style('height', '0%')
				
				d3.json 'data/countries/'+country+'.json', (data) ->
					scores = data[filter]
					for key in matieres
						score = scores[key]['score']

						d3.select('#test .'+key+' .preetyName').text scores[key]['preetyName']
						d3.select('#test .'+key+' .score').text score

						percentage = score * 100 / 1000

						d3.select('#test .'+key+' .graph-bar').transition().duration(1000).style('height', percentage+'%')

			when 'ratioHF'
				d3.selectAll('#ratioHF div').remove()

				ratios = []
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					ratios = data[filter]
					for key in cycles
						man   = ratios[key]['man']
						women = ratios[key]['women']

						ratio = [{"label": "Homme", "value": man, "color": "#f6c37a", "textColor": '#834d00'},
								 {"label": "Femme", "value": women, "color": "#45b4a4", "textColor": '#005046'}]

						width  = 150
						height = 150
						radius = 75

						vis = d3.select('#ratioHF')
							.append('div')
								.classed(key, true)
								.append('svg:svg')
								.data([ratio])
									.attr('width', width)
									.attr('height', height)
								.append('svg:g')
									.attr('transform', 'translate('+radius+','+radius+')')

						d3.select('#ratioHF > div:last-child')
							.append('span')
								.classed('preetyName', true)
								.text (d, i) -> ratios[key].preetyName

						arc = d3.svg.arc()
							.outerRadius(radius)

						pie = d3.layout.pie()
							.value (d) -> d.value

						arcs = vis.selectAll('g.slice')
							.data(pie)
							.enter()
								.append('svg:g')
									.attr('class', 'slice')

						arcs.append('svg:path')
							.attr('fill', (d, i) -> ratio[i].color)
							.attr('d', arc)

						arcs.append('svg:text')
							.attr 'transform', (d) ->
								d.innerRadius = 0
								d.outerRadius = radius
								"translate(" + arc.centroid(d) + ")"

							.attr('text-anchor', "middle")
							.attr('fill', (d, i) -> ratio[i].textColor)
							.attr('style', 'font-size:.7em')
							.text((d, i) -> ratio[i].value+'%')

			when 'sport'
				d3.selectAll('#sport div').remove()

				ratios = []
				cycles = ['primaire', 'college', 'lycee']
				d3.json 'data/countries/'+country+'.json', (data) ->
					ratios = data[filter]
					for key in cycles
						minPercentage  = ratios[key]['minPercentage']
						minHoursByYear = ratios[key]['minHoursByYear']

						ratio = [{"label": "", "value": minPercentage, "color": "#f6c37a", "textColor": '#834d00'},
								 {"label": "", "value": (100-minPercentage), "color": "#45b4a4", "textColor": '#005046'}]

						width  = 150
						height = 150
						radius = 75

						vis = d3.select('#sport')
							.append('div')
								.classed(key, true)
								.append('svg:svg')
								.data([ratio])
									.attr('width', width)
									.attr('height', height)
								.append('svg:g')
									.attr('transform', 'translate('+radius+','+radius+')')

						d3.select('#sport > div:last-child')
							.append ('span')
								.classed('info', true)
								.text (d, i) -> '(Soit '+ratios[key].minHoursByYear+' heures par an)'
						d3.select('#sport > div:last-child')
							.append('span')
								.classed('preetyName', true)
								.text (d, i) -> ratios[key].preetyName

						arc = d3.svg.arc()
							.outerRadius(radius)

						pie = d3.layout.pie()
							.value (d) -> d.value

						arcs = vis.selectAll('g.slice')
							.data(pie)
							.enter()
								.append('svg:g')
									.attr('class', 'slice')

						arcs.append('svg:path')
							.attr('fill', (d, i) -> ratio[i].color)
							.attr('d', arc)

						arcs.append('svg:text')
							.attr 'transform', (d) ->
								d.innerRadius = 0
								d.outerRadius = radius
								"translate(" + arc.centroid(d) + ")"

							.attr('text-anchor', "middle")
							.attr('fill', (d, i) -> ratio[i].textColor)
							.attr('style', 'font-size:.7em')
							.text((d, i) -> ratio[i].value+'%')

			else
				return


# Triggers on filter selection in single country view
filters = 
	onMouseOver: () ->
		# Get the filter information
		info = d3.select(this).attr('data-filter')

		# Search in json database which filter need to be used
		d3.json 'data/filters.json', (root) ->
			# Set the short text in top navigation
			d3.select('#active-filter').text(root[info].short)
	
	onMouseLeave: () ->
		# When mouseleave, we want to keep just the filter which is clicked
		filterList.selectAll('div')
			.each () ->
				# We have to find the one which have active class
				if d3.select(this).classed('active') is true
					# Get the filter information
					info = d3.select(this).attr('data-filter')
					# Search in json database which filter need to be used
					d3.json 'data/filters.json', (root) ->
						# Set the short text in top navigation
						d3.select('#active-filter').text(root[info].short)					

	onClick: () ->
		# Some vars
		el = d3.select(this)
		info = d3.select(this).attr('data-filter')
		
		# Remove all class active and add on clicked filter
		filterList.selectAll('div').classed('active', false)
		el.classed('active', true)

		# Complete the top navigation
		d3.json 'data/filters.json', (root) ->
			d3.select('#active-filter').text(root[info].short)

		# Initialization of graph with good filter
		graph.init(info)

datas = 
	init: () ->
		# Visual blocks transitions
		d3.select('#leftContent').classed('extended', true)
		d3.select('#displayData').classed('dataPanelOpened', true)
		d3.select('#filters').classed('closed', true)

		# Reinitialize map
		map.init()

		# Better with short vars (much preety)
		el = d3.select(this)

		d3.select('#displayData').attr('data-pays', el.attr('data-pays'))
		
		# Display data for country selected
		d3.json 'data/countries/'+el.attr('data-pays')+'.json', (root) ->
			d3.select('#datas h2').text modelEducatif+root.preposition+el.attr('data-pays')

	close: () ->
		# Visual blocks transitions (back to default)
		d3.select('#leftContent').classed('extended', false)
		d3.select('#displayData').classed('dataPanelOpened', false)
		d3.select('#filters').classed('closed', false)


# On click on reset button... we reset...
d3.select('.reset-map').on 'click', map.init

# Action to do on loading page and trigger events
polygon
	.on 'mouseover', map.onMouseOver
	.on 'mouseleave', map.onMouseLeave
	.on 'click', map.onClick
	# Fill countries (depends of if we have datas)
	.each (d) ->
		d3.select this
			.attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive


# Action to do when click event on a filter
filterList
	.on 'mouseleave', filters.onMouseLeave
	.selectAll('div')
	.on 'mouseover', filters.onMouseOver
	.on 'click', filters.onClick

# Action on click more-info button
d3.select('.more-info')
	.on 'click', datas.init

# Action on click right arrow
d3.select('#closeDataView')
	.on 'click', datas.close