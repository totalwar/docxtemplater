#This class responsibility is to manage the scope
DocUtils=require('./docUtils')

module.exports=class ScopeManager
	constructor:(@tags,@scopePath,@usedTags,@scopeList,@parser)->
	loopOver:(tag,callback,inverted=false)->
		value = @getValue(tag)
		type = typeof value
		if inverted
			return callback(@scopeList[@num]) unless value
			return if type == 'string'
			if type == 'object' && value.length < 1
				callback(@scopeList[@num])
			return
		return unless value?
		if type == 'object'
			for scope,i in value
				callback(scope)
		if value == true
			callback(@scopeList[@num])
	getValue:(tag,@num=@scopeList.length-1)->
		scope=@scopeList[@num]
		parser=@parser(DocUtils.wordToUtf8(tag))
		result=parser.get(scope)
		if result==undefined and @num>0 then return @getValue(tag,@num-1)
		result
	getValueFromScope: (tag) ->
		# search in the scopes (in reverse order) and keep the first defined value
		result = @getValue(tag)
		if result?
			if typeof result=='string'
				@useTag(tag)
				value= result
				if value.indexOf(DocUtils.tags.start)!=-1 or value.indexOf(DocUtils.tags.end)!=-1
					throw new Error("You can't enter #{DocUtils.tags.start} or	#{DocUtils.tags.end} inside the content of the variable. Tag: #{tag}, Value: #{result}")
			else if typeof result=="number"
				value=String(result)
			else value= result
		else
			@useTag(tag)
			value= "undefined"
		value
	#set the tag as used, so that DocxGen can return the list off all tags
	useTag: (tag) ->
		u = @usedTags
		for s,i in @scopePath
			u[s]={} unless u[s]?
			u = u[s]
		if tag!=""
			u[tag]= true
