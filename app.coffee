#-----------------------------------------------
# Variables

curve = 'bezier-curve(0.23, 1, 0.32, 1)'
time = '0.4'

columns = 2
row = 0
gutter = 8

contentZ = 0
appBarZ = 10
statusBarZ = 20
navBarZ = 30

cards = [
	{
		label: 'Card 1'
	},
	{
		label: 'Card 2'
	},
	{
		label: 'Card 3'
	},
	{
		label: 'Card 4'
	},
	{
		label: 'Card 5'
	}
]
		
#-----------------------------------------------
# Classes

#############
# CARD
class Card extends Layer

	constructor: (options={}) ->
		
		this.state = 0
		
		options.backgroundColor ?= "#fff"
		options.borderRadius ?= "2px"
		options.shadowX ?= 0
		options.shadowY ?= 1
		options.shadowBlur ?= 3
		options.shadowColor ?= "rgba(0, 0, 0, 0.25)"
		options.startY ?= 0
		options.width ?= (options.superLayer.width / columns) - (gutter * 1.5)
		options.height ?= (options.superLayer.width / columns) - (gutter * columns)		
		options.x = gutter
		options.y = gutter + options.startY
		
		if index %2 == 1
			options.x = options.width + (gutter*2)
		if index%2 == 0 && index !=0
			row++
		
		options.y = options.startY + (options.height * row) + (gutter * (row + 1))
				
		this.startWidth = options.width
		this.startHeight = options.height
		this.startX = options.x
		this.startY = options.y		
				
		super options
		
		# Display
		label = new Layer
			superLayer: this
			width: this.width
			height: this.height
			backgroundColor: 'transparent'
			x: 16
			y: 5
			opacity: 0.4
		label.style =
			color: 'rgba(0,0,0,1)'
			fontFamily: 'Roboto'
			fontSize: '10pt'
			fontWeight: '400'
		label.html = options.data.label
		
		backButton = new Layer
			image: 'images/back.png'
			width: 16
			height: 16
			x: 16
			y: 10
			opacity: 0
			
			superLayer: this
		# Events
		this.on Events.Click, (event, card) ->
			if this.state == 0
				@open()
			
		backButton.on Events.Click, (event,button) ->
			this.superLayer.close()
	
	open: =>
		console.dir "open"
		this.state = 1
		this.z = navBarZ - 1
		this.superLayer.z = appBarZ + 1
		
		animation = this.animate
			properties:
				borderRadus: "0"
				width: Screen.width
				height: Screen.height
				x: 0
				y: 0
			curve: curve
			time: time
		
		# Highlight
		Highlight = new Layer
			backgroundColor: 'rgba(0,0,0,.03)'
			borderRadius: '50%'
			width: 10
			height: 10
			opacity: 1
			ignoreEvents: true
			superLayer: this
		
		Highlight.x = event.clientX - (this.superLayer.width/2)
		Highlight.y = event.clientY - (this.superLayer.height/2) 
		
		highlightAnimation = Highlight.animate 
			properties:
				x: this.superLayer.x - 200
				y: this.superLayer.y - 200
				width: this.superLayer.width * 3
				height: this.superLayer.height * 3
				opacity: 1
			time: .3
			curve: 'ease'
    
    # Fade & Reset Highlight
		highlightAnimation.on "end" , ->
      Highlight.animate
        properties:
          opacity: 0
        curve: curve
				time: 0.06
				x: Highlight.x - 10
				y: Highlight.y - 10
			Utils.delay 0.06, ->
        Highlight.width = 80
				Highlight.height = 80
		
		this.subLayers[0].animate
			properties:
				scale: 1.15
				opacity: .5
				x: 64
				y: 48
			curve: curve
			time: time
		
		this.subLayers[1].animate
			properties:
				x: 16
				y: 43
				opacity: .6
			curve: curve
			time: time
		
	
	close: =>
		console.dir "close"
		this.state = 0
		this.superLayer.animate
			properties:
				z: contentZ
			time: time
		animation = this.animate
			properties:
				width: this.startWidth
				height: this.startHeight
				x: this.startX
				y: this.startY
				z: contentZ
			curve: curve
			time: time
		
		this.subLayers[0].animate
			properties:
				scale: 1
				opacity: .4
				x: 10
				y: 5
			curve: curve
			time: time
		
		this.subLayers[1].animate
			properties:
				x: 16
				y: 10
				opacity: 0
			curve: curve
			time: time
			

	layout: =>

#############
# APPBAR
class AppBar extends Layer
	constructor: (options={}) ->
		
		options.theme ?= 'light'
		options.backgroundColor ?= "rgba(255,255,255,1)"
		options.width ?= options.superLayer.width
		options.height ?= 80
		
		options.shadowX ?= 0
		options.shadowY ?= 1
		options.shadowBlur ?= 3
		options.shadowColor ?= "rgba(0, 0, 0, 0.25)"
		
		options.title ?= "Cards"
		
		if options.theme == 'dark'
			textColor = 'rgba(255,255,255,1)'
		else
			textColor = 'rgba(0,0,0,.5)'
		
		super options
		
		# title
		title = new Layer 
			backgroundColor: "transparent", 
			width: this.width,
			height: 56,
			y: 24, 
			superLayer: this
		title.html = options.title
		title.style =
			color: textColor
			fontSize: '16px'
			fontFamily: 'Roboto'
			textAlign: 'left'
			lineHeight: '56px'
			padding: '0 0 0 50px'
		
		# menu control
		menuControl = new Layer
			backgroundColor: 'transparent'
			opacity: .6
			x: 16
			y: 46
			height: 12
			width: 18
			superLayer: this
		
		barHeight = menuControl.height/4
		
		menuControlBar1 = new Layer
			backgroundColor: textColor
			width: menuControl.width
			height: barHeight
			superLayer: menuControl
		menuControlBar2 = new Layer
			backgroundColor: textColor
			width: menuControl.width
			height: barHeight
			y: barHeight + (barHeight/2)
			superLayer: menuControl
		menuControlBar3 = new Layer
			backgroundColor: textColor
			width: menuControl.width
			height: barHeight
			y: (barHeight*2) + (barHeight)
			superLayer: menuControl
		
		menuControl.on Events.Click, (event, button) ->
			sideNav.open()

#############
# NAVBAR
class Navbar extends Layer

	constructor: (options={}) ->
		
		options.backgroundColor ?= "rgba(0,0,0,1)"
		options.width ?= options.superLayer.width
		options.height ?= 48
		options.y = options.superLayer.height - options.height
		
		super options
		
#############
# STATUSBAR
class StatusBar extends Layer
	constructor: (options={}) ->
		
		options.backgroundColor ?= "rgba(0,0,0,.2)"
		options.height ?= 24
		options.width = options.superLayer.width
		
		super options

#############
# STATUSBAR
class StatusBar extends Layer
	constructor: (options={}) ->
		
		options.backgroundColor ?= "rgba(0,0,0,.2)"
		options.height ?= 24
		options.width = options.superLayer.width
		
		super options

#############
# CONTENT
class Content extends Layer
	constructor: (options={}) ->
		
		options.backgroundColor ?= "transparent"
		options.height ?= options.superLayer.height
		options.width = options.superLayer.width
		
		super options

# MENU
class SideNav extends Layer
	constructor: (options={}) ->
		
		options.backgroundColor ?= "rgba(255,255,255,.95)"
		options.height ?= options.superLayer.height
		options.width ?= options.superLayer.width - 60
		options.x = -(options.superLayer.width - 60)
		options.z ?= statusBarZ
		
		options.shadowX = 0
		options.shadowBlur = 0
		options.shadowColor = "rgba(0, 0, 0, 0.25)"
		
		super options
		
		# Events
		this.draggable.enabled = true
		this.draggable.speedY = 0
		this.on Events.DragEnd, (event, object) ->
			if (object.x < -50)
				object.animate
					properties:
						x: -object.width
						shadowX: 0
						shadowBlur: 0
					time: time
					curve: curve
			else
				object.animate
					properties:
						x: 0
						y: 0
					time: time
					curve: curve
	open: =>
		this.state = 1
		
		animation = this.animate
			properties:
				x: 0
				y: 0
				shadowX: 5
				shadowBlur: 20
			curve: curve
			time: time
		
		
#############	
# VIEW
class View extends Layer
	
	constructor: (options={}) ->
		options.width ?= options.superLayer.width
		options.height ?= options.superLayer.height
		options.backgroundColor = "#f7f7f7"
		
		super options
		
		content = new Content
			name: 'content'
			superLayer: this
			z: contentZ
		
		appBar = new AppBar
			name: 'appBar'
			superLayer: this
			z: appBarZ
		
		statusBar = new StatusBar
			name: 'statusBar'
			superLayer: this
			z: statusBarZ
		
		navBar = new Navbar
			name: 'navBar'
			superLayer: this
			z: navBarZ
	

# DASHBOARD

canvas = new Layer
	width: 360
	height: 640
canvas.centerX()
canvas.centerY()
	
dashboard = new View
	superLayer: canvas

sideNav = new SideNav
	superLayer: canvas
	z: navBarZ - 1
	superLayer: dashboard

for data, index in cards
	card = new Card
		data: data
		startY: 80
		superLayer: dashboard.subLayers[0]
