require 'js-yaml'
cp=require 'child_process'
cfg=require process.argv[2]||'./config.yaml'
fs=require 'fs'
exiting=false
exited=0
processes=cfg.services.map (service,i)->
	console.log "#{service.cmd} started..."

	pexit=(error,stdout,stderr)->
		[o,c,i]=this.sync
		if o.stdout&&stdout?
			fs.appendFileSync o.stdout,stdout,'utf8'
		if o.stderr&&stderr?
			fs.appendFileSync o.stderr,stderr,'utf8'
		if exiting
			exited++
			if exited==processes.length
				process.exit 0
		else
			console.log "#{c} stopped..."
			setTimeout (->
				console.log "#{c} restarted..."
				processes[i]=cp.exec c,o
				processes[i].on 'exit',pexit
				processes[i].sync=[o,c,i]
				),2000
	process=cp.exec service.cmd,service.option
	process.on 'exit',pexit
	process.sync=[service.option,service.cmd,i]
	process
process.on 'SIGTERM',->
	exiting=true
	for process in processes
		if !process.exited
			try
				process.kill 15
			catch e
	setTimeout (->
		process.exit 1
		),5000