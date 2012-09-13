LocalPROXY make your node-dev-life easier!!
===================================================

##Installation

	npm install iced-coffee-script -g

##Usage

	localproxy$ iced ./ ../config.yaml

##Reload config

visit any link contains [?localproxy-reset](?localproxy-reset)

##Example config file

	defaultHost: 'localhost'
	defaultPort: 2999
	defaultPath: '/'
	hosts:
	  'pccweb':
	    'port': 3000
	  'cmd':
	    'port': 2998
	  'pccweb/api':
	    'host': 'wuruile-pc'
	    'port': 6001
	    'path': '/pccweb/servlet'
	