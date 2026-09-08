"I identify the staged source CPShape for one contextual append drag. The dragged candidate itself remains the BlDragItem domain object."
Class {
	#name : 'CPProcessContextualAppendDragContext',
	#superclass : 'Object',
	#instVars : [ 'sourceShape' ],
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}

{ #category : 'instance creation' }
CPProcessContextualAppendDragContext class >> sourceShape: aShape [
	^ self new sourceShape: aShape; yourself
]
{ #category : 'accessing' }
CPProcessContextualAppendDragContext >> sourceShape [ ^ sourceShape ]
{ #category : 'accessing' }
CPProcessContextualAppendDragContext >> sourceShape: aShape [ sourceShape := aShape ]
