Class {
	#name : 'CPProcessCompiler',
	#superclass : 'Object',
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'compiling' }
CPProcessCompiler >> compileDesign: aDesign [
	| validation definition compiled |
	validation := self validateDesign: aDesign.
	validation isValid ifFalse: [ ^ CPProcessCompilationResult failedValidation: validation ].
	definition := self buildDefinitionFrom: aDesign.
	compiled := self buildCompiledDefinitionFrom: definition.
	^ CPProcessCompilationResult definition: definition compiledDefinition: compiled validation: validation
]

{ #category : 'validation' }
CPProcessCompiler >> validateDesign: aDesign [
	^ CPProcessDesignValidator new validateDesign: aDesign
]

{ #category : 'building' }
CPProcessCompiler >> buildDefinitionFrom: aDesign [
	| definition nodeMap |
	definition := CPProcessDefinition new
		identifier: aDesign identifier;
		label: aDesign label;
		comment: aDesign comment;
		sourceDesign: aDesign;
		processKey: aDesign identifier;
		yourself.
	nodeMap := Dictionary new.
	aDesign nodes do: [ :designNode |
		| node |
		node := self buildNodeDefinitionFrom: designNode.
		nodeMap at: designNode put: node.
		definition nodes add: node ].
	aDesign edges do: [ :designEdge |
		definition transitions add: ((CPTransitionDefinition new)
			identifier: designEdge identifier;
			label: designEdge label;
			comment: designEdge comment;
			sourceNode: (nodeMap at: designEdge sourceNode);
			targetNode: (nodeMap at: designEdge targetNode);
			condition: designEdge condition;
			isDefault: designEdge isDefault;
			sourceDesignEdge: designEdge;
			yourself) ].
	^ definition
]

{ #category : 'building' }
CPProcessCompiler >> buildNodeDefinitionFrom: aDesignNode [
	| class |
	class := aDesignNode isStartNode ifTrue: [ CPStartEventDefinition ] ifFalse: [
		aDesignNode isEndNode ifTrue: [ CPEndEventDefinition ] ifFalse: [
			aDesignNode class = CPUserTaskDesignNode ifTrue: [ CPUserTaskDefinition ] ifFalse: [
				aDesignNode class = CPServiceTaskDesignNode ifTrue: [ CPServiceTaskDefinition ] ifFalse: [
					aDesignNode class = CPExclusiveGatewayDesignNode ifTrue: [ CPExclusiveGatewayDefinition ] ifFalse: [ CPParallelGatewayDefinition ] ] ] ] ].
	^ class new
		identifier: aDesignNode identifier;
		label: aDesignNode label;
		comment: aDesignNode comment;
		sourceDesignNode: aDesignNode;
		yourself
]

{ #category : 'building' }
CPProcessCompiler >> buildCompiledDefinitionFrom: aDefinition [
	^ CPCompiledProcessDefinition new
		definition: aDefinition;
		indexDefinition;
		yourself
]

