# SVG element
svg = d3.select('svg')

# Height and width from window
height = window.innerHeight
width = window.innerWidth

# Height and width from svg
svgHeight = svg.attr('height')
svgWidth = svg.attr('width')

# Countries where we have some datas
countries = ['Espagne', 'France', 'Italie', 'Grèce', 'Allemagne', 'Belgique', 'Royaume-Uni', 'Irlande', 'Suède', 'Finlande', 'Norvège']

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
	changePointer: () ->
		# Pointer on available countries
		svg.selectAll('polygon').each () ->
			console.log('coucou')
			if d3.select(this).attr('fill') != inactive then d3.select(this).style('cursor', 'pointer')
	onMouseOver: () ->
		# Fill with another color on hover
		map.changePointer()
		el = d3.select(this)
		country = el.attr 'data-pays'
		svg.selectAll('polygon').each () ->
			if el.attr('fill') != inactive && d3.select(this).attr('data-pays') == country then d3.select(this).attr('fill', hover)
	onMouseLeave: () ->
		# Reset default background color on mouse leave country
		svg.selectAll('polygon').each () ->
			if d3.select(this).attr('fill') != inactive then d3.select(this).attr('fill', active)


svg.selectAll 'polygon'
	# Change color on mouseover
	.on 'mouseover', map.onMouseOver
	.on 'mouseleave', map.onMouseLeave
	# Fill countries (depends of if we have datas)
	.each () ->
		d3.select this
			.attr 'fill', () ->
				if countries.indexOf(d3.select(this).attr('data-pays')) > -1 then active else inactive

