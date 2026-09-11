# CURRENT CONTINUATION SNAPSHOT — 12 September 2026, ~08:40 Sydney

This section supersedes the 11 September continuation snapshot below for current implementation status and continuation advice. The older snapshots are retained as historical evidence of the evolution of the implementation and rejected approaches.

## A. Current accepted baselines

### Foundation Detail

The accepted Foundation grouped-buttons single-option representation remains:

- `Foundation-Sep11-0640-patchA-grouped-buttons-single-option.zip`

The user runtime-confirmed this all green. It remains the correct reusable Foundation Detail primitive for the Pool orientation field.

### Process orientation — current green code baseline

The current accepted Process baseline is:

- `ProcessSep11-0640-patchBM-orientation-audit-cleanup.zip`

The user explicitly reported **all green** after BM.

BM was a behavior-preserving cleanup built on the runtime-verified BL orientation handoff. Its important architectural cleanup was:

- shared presentation-independent Pool/Lane quarter-turn geometry moved to `BVC-BPM-BPMN` as `CPPoolLaneGeometry`;
- Atelier owns assessment/application of the authoritative DI edit;
- GT owns projection and Motion only;
- obsolete experimental Participant-Motion behavior from BK was removed;
- connection-label linear correction returned to ordinary Foundation `CFMotionTranslationTrack`;
- the custom external-label Motion behavior remained because the then-current flat animation structure still required a progress-dependent screen-space correction;
- the verified one-pixel Process-content handoff correction remained in GT, not in persisted BPMN-DI geometry.

Immediately before BM, `ProcessSep11-0640-patchBL-process-content-handoff-pixel-fix.zip` was runtime-confirmed by the user as **“perfect.”** BL removed the final approximately one-pixel endpoint jump for the Process content that existed at that time.

Do not regress the core orientation invariant: the DI operation is an exact rigid quarter-turn of the Pool coordinate system; Pool/Lane structure rotates, FlowNode centres rotate, FlowNode extents remain upright, and edge waypoints rotate.

## B. New runtime finding after BM — Boundary Event exposes a structural animation flaw

After BM was all green, the user added a Boundary Event. During Pool orientation animation the Boundary Event jumps at the final authoritative refresh.

This is important evidence: the problem is **not** that Boundary Events need one more endpoint correction. The current animation architecture is too flat. If every newly composed diagram feature must be added to an orientation target/correction list, the projection is not preserving the visual composition of the BPMN node.

The user identified the preferred direction:

> transform node centres through the rotation; keep the things that must remain upright upright; make the Bloc projection compose a node and its adornments so Motion acts on the composition rather than knowing every adornment type individually.

That direction is supported by current source structure.

### Exact source evidence for the flaw

`CPProcessShapeElement>>hostBoundaryEventElement:atLocalPosition:` makes the Boundary Event a genuine Bloc child of its attached Activity:

```smalltalk
CPProcessShapeElement >> hostBoundaryEventElement: aBoundaryElement atLocalPosition: aPoint [
    aBoundaryElement constraintsDo: [ :c | c ignoreByLayout ].
    self addChild: aBoundaryElement.
    aBoundaryElement relocate: aPoint.
    self forceLayout
]
```

`CPProcessVisualElement>>addShapeFor:hostedByActivityElement:` deliberately uses that containment for Boundary Events:

```smalltalk
modelElement isBoundaryEvent
    ifTrue: [
        anActivityElement
            hostBoundaryEventElement: element
            atLocalPosition: bounds origin
                - (self stagedBoundsOf: anActivityElement diagramShape) origin ]
```

But the orientation code later discards that hierarchy conceptually. `CPProcessVisualElement>>orientationUprightElements` flattens all shape visuals into independent Motion targets:

```smalltalk
shapeElementsByShape valuesDo: [ :aShapeElement |
    elements add: aShapeElement.
    aShapeElement externalLabelHost ifNotNil: [ :aLabel |
        elements add: aLabel ] ].
```

This includes both an Activity and its hosted Boundary Event. `CPProcessPresentation>>animateParticipantOrientationFor:horizontal:assessment:commit:` then installs an independent inverse `CFMotionRotationTrack` on every entry in that flattened collection.

That is the wrong abstraction boundary. A visual that is already a descendant of another animated visual must not be treated as though it were an unrelated top-level diagram object. The resulting transform depends on parent/child transform composition and creates exactly the kind of feature-by-feature correction burden now being observed.

### Foundation Motion source fact

In the supplied accepted Foundation source, no dedicated class or selector named `keepUpright`, `upright`, `counterRotate`, or equivalent was found in `BVC-Motion-Core`. The relevant primitive is `CFMotionRotationTrack`, whose presentation participates in Motion's shared transform channel. Therefore do not rely on a presumed `keepUpright` API without checking a newer Foundation source.

A clean keep-upright behavior can still be expressed using Foundation Motion: apply an inverse rotation track to the appropriate **visual layer**, not to every semantic/DI shape independently.

## C. Recommended orientation projection architecture

The next orientation work should stop extending `orientationUprightElements`, `orientationExternalLabelOffsets`, and per-feature endpoint-correction dictionaries. The goal should be a compositional projection where new adornments naturally inherit the correct behavior.

### 1. Separate a node's orbital frame from its upright visual frame

A FlowNode presentation should have a stable node-centred composition. Conceptually:

```text
FlowNode orbital frame       -- centred on CPShape bounds centre
|
+-- upright body frame       -- inverse rotation cancels Pool rotation
|   +-- node body
|   +-- body-internal markers/icons
|   +-- ordinary external node label, if its contract is screen-upright/below-node
|
+-- rotating attachment frame
    +-- Boundary Event attachment slot(s)
        +-- upright Boundary Event glyph/body
```

The **orbital frame** is the important missing abstraction. Its centre follows the Pool quarter-turn. It inherits the Pool rotation, so relative attachment positions rotate naturally. It is not itself counter-rotated.

The **upright body frame** is counter-rotated through Foundation Motion. The node body therefore remains upright while its centre travels around the Pool centre.

This distinction matters for Boundary Events. Their attachment point must rotate from one edge of an Activity to the corresponding rotated edge, so the Boundary Event position belongs in the rotating/orbital frame. But the Boundary Event symbol itself should remain upright, so only its glyph/body presentation gets the inverse rotation. Do **not** counter-rotate the entire Activity container and then independently counter-rotate the Boundary Event child again.

### 2. The node centre is the single geometric anchor

The authoritative Atelier assessment already does the right high-level thing. `CPAtelierSetParticipantOrientation>>assess` computes every non-Lane shape's new bounds using `rotateUprightBounds:within:`. That means the authoritative model is already based on rotating each shape centre while preserving its extent.

The projection should mirror that rule rather than deriving Motion from each concrete visual subtype:

```text
current node centre
    -> exact quarter-turn through CPPoolLaneGeometry
    -> Motion carries node orbital frame centre to that destination
    -> upright layer receives inverse visual rotation
```

A node feature should normally not participate in orientation code at all. It should choose the correct node presentation layer when it is constructed.

### 3. Classify visual composition, not BPMN feature types

Prefer a very small set of presentation roles rather than checks such as “is Boundary Event?”, “has external label?”, etc. The useful roles are approximately:

- **rotates with diagram frame** — Lane structure, edge paths, attachment positions;
- **moves with diagram frame but remains upright** — FlowNode body, Boundary Event glyph, text/icon surfaces;
- **screen-relative adornment** — an ordinary external node label whose final renderer intentionally keeps it below an upright node;
- **path-relative upright adornment** — SequenceFlow label: its path anchor is derived from rendered edge geometry, but the label text stays upright.

These should be represented by containment/presentation objects, not by a central orientation method enumerating current BPMN features.

### 4. Boundary Event DI remains independent even if its visual is composed with the Activity

Do not change BPMN semantics or DI ownership to solve projection. A Boundary Event keeps its own `CPShape` and authoritative bounds. The Activity-owned visual composition is only a projection convenience.

At build time, derive the Boundary Event's local attachment vector from DI:

```text
boundaryEventShape centre - activityShape centre
```

Store/project that into the Activity orbital frame. When the Pool rotates, the orbital frame rotates the vector automatically. The Boundary Event's upright visual layer counter-rotates to remain readable. At the Motion endpoint, the resulting screen centre should equal the proposed Boundary Event DI shape centre without a Boundary-Event-specific handoff correction.

This gives a very strong regression: the Boundary Event centre produced by the composed visual transform at progress 1 must exactly equal `assessment proposedFlowNodeBoundsByShape` for the Boundary Event.

### 5. Ordinary node labels should become composition rather than procedural Motion corrections

The current `CPProcessOrientationExternalLabelMotionBehaviour` exists because external labels are explicitly reparented to the diagram root by `bringNodeInteractionSurfacesToFront` / `bringExternalLabelToFrontIn:`. Once detached from their node, Motion has to reconstruct the desired relation procedurally.

That is a code smell for orientation. If z-order can be achieved without destroying ownership, prefer keeping a node label inside a node-level upright adornment layer. Then “stay below this upright node” is ordinary layout inside the node composition and no progress-dependent orientation behavior is needed.

If Bloc requires a root overlay for hit-testing/z-order, introduce an explicit projection/portal abstraction that preserves the node-relative coordinate contract; do not make orientation code rediscover ownership from dictionaries.

### 6. SequenceFlow labels are a separate composition problem, but still should not be feature-specific

A connection label is not owned by a FlowNode. Its authoritative anchor is `CPProcessEdgeLabelPath`, derived from the rendered edge path. Since FlowNodes stay upright while DI waypoints rotate, final endpoint docking is not necessarily the rigidly rotated old rendered path. Therefore an edge label may still need Motion based on the proposed rendered edge path.

But that should be an **edge presentation-unit rule**, not a special case in Participant orientation. A useful target structure is:

```text
Edge presentation
+-- path geometry frame
+-- label anchor/frame following CPProcessEdgeLabelPath
    +-- upright label visual
```

Then orientation asks the edge presentation to animate from current projected geometry to the assessed projected geometry; the Participant orientation method does not calculate connection-label centres itself.

## D. Layering rules for the redesign

Keep these boundaries strict:

### BPMN / DI (`BVC-BPM-BPMN`)

Owns presentation-independent exact geometry only:

- `CPShape>>isHorizontal`;
- `CPPoolLaneGeometry` quarter-turn mathematics;
- BPMN-DI shape/edge data.

It must know nothing about Bloc, Motion, labels, Boundary Event visual hosting, or pixels.

### Atelier (`BVC-BPM-Atelier`)

Owns the authoritative edit assessment and application:

- target Participant/Lane orientation;
- proposed Participant/Lane bounds;
- proposed FlowNode bounds (centre rotated, extent preserved);
- proposed SequenceFlow waypoints;
- proposed collaboration endpoint waypoints;
- validation and memento writes.

It must not know how a Boundary Event is visually hosted or which child visuals stay upright.

### GT projection (`BVC-BPM-GT`)

Owns visual composition:

- FlowNode orbital/upright/adornment frames;
- Activity/Boundary Event projection relationship;
- external-label projection relationship;
- edge/path/edge-label projection;
- mapping DI geometry into Bloc geometry.

This is the correct layer for solving the new Boundary Event issue.

### Foundation Motion

Owns animation and transform interpolation exclusively. Process may compose Motion tracks/behaviors over its projection objects, but must not introduce separate animation loops or timing systems.

## E. Specific current code to reconsider/remove after the compositional projection exists

Do not delete these until the replacement is proven by regressions, but they are now redesign targets rather than architecture to preserve:

- `CPProcessVisualElement>>orientationUprightElements`
- `CPProcessVisualElement>>orientationExternalLabelOffsets`
- `CPProcessVisualElement>>orientationConnectionLabelCorrectionsForAssessment:horizontal:`
- `CPProcessVisualElement>>orientationContentHandoffCorrectionForAssessment:horizontal:`
- `CPProcessOrientationExternalLabelMotionBehaviour`
- the large feature-aware loop inside `CPProcessPresentation>>animateParticipantOrientationFor:horizontal:assessment:commit:`

The goal is that `animateParticipantOrientationFor:` knows about the Participant/Process projection as a few compositional animation units, not every current node/adornment type.

BL's one-pixel handoff correction is accepted runtime evidence, but in the new architecture treat it as evidence that the old flat projection had a coordinate-boundary mismatch—not as a permanent rule that every child presentation should inherit. Re-test whether it is still needed after node-centred composition is in place.

## F. Regression strategy before removing old orientation code

The next implementation should be driven by composition-level regressions. At minimum prove:

1. A plain Task centre follows the exact assessed quarter-turn and its body stays upright.
2. An Event/Gateway behaves identically without type-specific animation code.
3. A Task with an external label keeps the label's renderer-defined relation without a label-specific Participant-orientation correction.
4. An Activity with a Boundary Event ends with both centres exactly equal to their assessed DI bounds and both glyphs upright.
5. Multiple Boundary Events on different Activity edges rotate to the corresponding edges correctly.
6. SequenceFlow path and label end exactly at the authoritative projected path/label placement.
7. Horizontal→vertical→horizontal restores exact DI geometry and produces no visual handoff jump.
8. The existing canonical horizontal Pool/Lane regression remains green.

Use `assert:` only in GT examples. Do not use `deny:`. Do not use ordinal collection selectors beyond `ninth`.

## G. Immediate next investigation

Before writing another patch, inspect whether the current `CPProcessShapeElement` can be safely split internally into explicit orbital/body/adornment hosts without changing its public interaction contract. Pay particular attention to:

- selection and drag event surfaces;
- resize handles;
- connection anchors;
- popup/type affordances;
- expanded SubProcess nested visuals;
- Boundary Event hit-testing and drag behavior;
- z-order currently achieved by reparenting labels to `diagramPresentationParent`.

The preferred result is **one transformable node projection with explicit sublayers**, not more orientation lookup dictionaries.

---

# CURRENT CONTINUATION SNAPSHOT — 11 September 2026, ~23:10 Sydney

This section supersedes the 10 September continuation snapshot below for current implementation status and continuation advice. The older material is retained because it contains the original Definitions-root refactor evidence, source audit, class map and historical failure analysis.

## A. Current accepted baselines

### Foundation

The new typed Detail field representation for a grouped-buttons single-option editor is **runtime confirmed green**.

Current accepted Foundation artifact:

- `Foundation-Sep11-0640-patchA-grouped-buttons-single-option.zip`

Key additions:

- `CFMaGroupedButtonsConfiguration` as a typed `CFMaFieldRepresentationConfiguration`.
- `CFMaFieldConfiguration>>beGroupedButtons`.
- `CFMaGroupedButtonsConfiguration>>addSingleOptionUsing:toDetailPresentation:`.
- `CFMaDetailGroupedButtonsElement`, implemented with `BrToggleGroup`.
- `CFMaDetailPresentation>>addGroupedButtonsSingleOptionUsing:`.
- Existing `MAOptionDescription>>blocOptionIconStencil` is used for icon choices; text is the fallback.
- Writes still go through the normal Foundation/GT Magritte memento path.

Focused examples `fieldConfigurationCanUseGroupedButtons` and `groupedButtonsAreMutuallyExclusive` were reported all green by the user.

This is now a reusable Foundation primitive; do not replace it with a Process-specific control.

### Process — stable horizontal Pool/Lane baseline

The last explicitly runtime-confirmed clean horizontal Pool/Lane baseline is:

- `ProcessSep11-0640-patchAR-horizontal-lane-final-cleanup.zip`

The horizontal work before orientation established DI-faithful Pool/Lane rendering, creation, insertion, nested Lane layout, content-aware Lane minimums, Lane deletion, node/edge movement during resize, live external-label and connection-label preview, and canonical horizontal regressions. Treat AR as the rollback point if later orientation work is found to have damaged unrelated horizontal behavior.

### Process — orientation baseline

`ProcessSep11-0640-patchAS-bpmn-di-pool-lane-orientation.zip` was explicitly reported **all green** by the user. It introduced BPMN-DI Pool/Lane orientation through `CPShape>>isHorizontal`, defaulting to true, and explicit orientation collaborators:

- `CPPoolLaneOrientation`
- `CPHorizontalPoolLaneOrientation`
- `CPVerticalPoolLaneOrientation`

The BPMN 2.0 source basis is that `BPMNShape::isHorizontal` is an optional attribute for Pools and Lanes that determines horizontal (`true`) versus vertical (`false`) depiction. Orientation belongs to DI, not to semantic `CPParticipant` or to a whole diagram.

## B. Pool orientation UI and editing behavior now established

The first consumer of Foundation grouped buttons is Pool orientation in Detail.

User-facing field:

- label: **Orientation**
- Vertical icon: `#squareHalfStroke`
- Horizontal icon: `#squareHalfStrokeHorizontal`

The field is shown for a selected Pool but must not invent a semantic `CPParticipant` orientation property. It adapts the Participant's DI `CPShape` and delegates the structural change to typed Process diagram editing.

Current editing messages are explicit, not symbol-dispatched:

```smalltalk
makeParticipantVertical: participantShape
makeParticipantHorizontal: participantShape
```

The operation changes the Participant DI orientation and all Lane DI orientations together. Pool/Lane semantic ownership and FlowNode Lane membership remain unchanged.

A lifecycle bug was found after the first successful horizontal→vertical switch: the Collaboration visual refresh rebuilt staged depiction context while the old Detail orientation adapter remained alive. `ProcessSep11-0640-patchAX-orientation-toggle-refresh-fix.zip` fixed this by rebuilding Pool Detail from the newly refreshed staged Collaboration state. User runtime result: **“works well.”** Bidirectional switching therefore worked at AX.

## C. Orientation geometry invariant — do not regress this

Orientation switching is **not ordinary Lane reflow**. The user explicitly requires it to look like a 90-degree rotation of the Pool coordinate structure.

Authoritative geometry rule:

1. The Pool keeps its centre and swaps width/height.
2. Pool and Lane rectangles are transformed by the same exact quarter-turn.
3. Nested Lane rectangles use the same transform.
4. FlowNode **centres** follow the same quarter-turn around the Pool centre.
5. FlowNode extents do **not** rotate; BPMN nodes remain upright.
6. SequenceFlow waypoint positions follow the quarter-turn.
7. Ordinary node labels and connection labels remain upright.
8. Pool/Lane header labels rotate with the Pool/Lane structure.
9. Horizontal→vertical→horizontal must restore original DI geometry, modulo only unavoidable numeric representation.

`ProcessSep11-0640-patchAV-rigid-pool-orientation-rotation.zip` replaced orientation-time Lane reflow with this rigid transform. Do not reintroduce `CPAtelierLaneLayout` as the authority for the orientation switch itself. Lane reflow remains correct for normal resize/editing after orientation has been chosen.

Relevant regressions added during this work include:

- `participantOrientationRotatesGeometryWithoutRotatingFlowNodes`
- `participantOrientationRoundTripRestoresExactGeometry`

The earlier fixture error using `tenth`, `twelfth` and `thirteenth` on `Array` was fixed by explicit `at:` indexing. Do not use ordinal collection accessors beyond `ninth`.

## D. Motion is mandatory for all visible animation

The user has made the project rule explicit: **all animation uses Foundation Motion exclusively.**

For Pool orientation:

- no Bloc animation API,
- no timers,
- no hand-written animation loops,
- no independent interpolation outside Motion.

The first Motion attempt committed/refreshed final DI before starting animation, producing a visible snap. That ordering was rejected.

`ProcessSep11-0640-patchAZ-seamless-motion-orientation-handoff.zip` changed the handoff to:

```text
existing authoritative presentation
    ↓
Foundation Motion rotates the existing Pool presentation to the exact quarter-turn endpoint
    ↓
only at the Motion endpoint, commit the matching DI transform
    ↓
refresh authoritative presentation
```

The transformed old presentation and refreshed new presentation therefore occupy the same geometry at the handoff. The user reported this **looks good**.

Motion behavior during the turn:

- Pool/Lane structure rotates.
- Pool/Lane header labels rotate with it.
- FlowNodes counter-rotate so their net screen orientation stays upright while their centres follow the Pool's circular path.
- Ordinary labels must also remain upright and must finish at exactly the placement the authoritative renderer derives after commit.

This seamless handoff sequence is accepted. Do not return to “commit, refresh, then animate from the beginning.”

## E. Remaining orientation animation defect — labels

The only currently reported visual defect is label placement during the Motion quarter-turn.

User runtime evidence from the supplied recording:

- external Event/Gateway labels start below their upright node,
- during rotation they travel to the **opposite edge / above** the node,
- at the end, authoritative refresh puts them back below,
- therefore a visible label jump remains,
- label calculations must cover both external FlowNode labels and connection labels.

Several endpoint-vector approaches were tried and rejected because the abstraction was wrong or the coordinate transform was wrong. Do not revive those patches wholesale:

- BA: endpoint corrective translation; labels travelled incorrectly.
- BB: corrected quarter-turn direction; improved but still opposite-edge handoff.
- BC: attempted screen-space owner offset; still wrong.
- BD: introduced `CPProcessOrientationExternalLabelMotionBehaviour`; runtime still showed below→above behavior.

Source inspection of BD found a concrete composition issue in the procedural external-label behavior. It used:

```smalltalk
translation = inverseRotatedOffset - offset
```

while the same label element simultaneously receives a Motion counter-rotation and the enclosing Pool receives its own Motion rotation. The translation contribution is composed in the element's Motion transform channel after the counter-rotation contribution, so the inverse-local formula is not the correct correction in that composition. The observed vertical sign error is consistent with this: the label is corrected toward the opposite screen-space edge.

A new candidate patch was prepared:

- `ProcessSep11-0640-patchBE-label-counterrotation-space-fix.zip`

BE changes the procedural correction to:

```smalltalk
translation = desiredScreenOffset - poolRotatedOffset
```

with the same Motion progress, so a below-node offset remains below instead of being converted to the inverse local offset. The clockwise/counter-clockwise examples were changed to assert that `rotatedOffset + correction = originalOffset`.

**BE is structurally audited but has not yet been runtime-confirmed by the user.** Treat it as a candidate, not a green baseline. If it still fails, stop changing signs. Instrument the actual Motion-composed label centre, node centre and Pool transform at progress 0, 0.25, 0.5, 0.75 and 1.0 in one live example and derive the correction from those observed coordinate spaces.

For connection labels, preserve this distinction:

- SequenceFlow geometry/waypoints rotate with the Pool.
- `CPProcessEdgeLabelPath` is the authoritative placement rule for the final rendered connection label.
- Connection label text must stay upright.
- At the Motion endpoint the label centre must equal the centre produced by the same `CPProcessEdgeLabelPath` rules after DI commit/refresh.

Do not invent a second permanent label geometry model in Motion.

## F. Relevant source added during orientation work

### BPMN DI

`CPShape` now has `isHorizontal`, default true, with Magritte description. Staged render paths must read the shape's staged orientation through the diagram memento, not only the committed object.

### Orientation presentation

`CPPoolLaneOrientation` and concrete horizontal/vertical subclasses own presentation-axis differences such as:

- Participant content origin offset,
- Lane body origin offset,
- Pool/Lane header band constraints,
- label rotation,
- insertion-axis interpretation.

Avoid scattered `ifHorizontal` geometry in renderers where the orientation collaborator already represents the policy.

### Orientation editing

The orientation operation is a DI geometry operation, distinct from normal Participant resize. It must atomically stage the Participant/Lanes/nodes/waypoints destination before the final commit/refresh handoff.

### Detail adapter

Pool Detail must resolve the current staged Participant shape after Collaboration refresh. Do not keep an adapter bound to a stale pre-refresh depiction object.

## G. Vertical Pool/Lane editing beyond orientation switch

A vertical resize/layout slice was implemented in `ProcessSep11-0640-patchAT-vertical-lane-resize-layout.zip`, adding width-based Lane minima and explicit vertical LaneSet reflow. Its runtime status was not recorded as separately user-confirmed before later orientation work proceeded, so do not overstate it as a green checkpoint.

Still to verify/finish for a complete vertical editing experience:

- first-Lane creation sizing for vertical Pools,
- Pool palette Lane insertion order along x rather than y,
- sibling Lane insertion/removal under vertical orientation,
- nested Lane creation/removal/reflow,
- drag/drop Lane targeting,
- content-aware minimum widths,
- vertical resize with nodes/waypoints/labels,
- horizontal canonical regressions after every vertical change.

Keep orientation switching (rigid quarter-turn) separate from these normal vertical editing policies (width-based reflow).

## H. Horizontal Pool/Lane architecture carried forward

The following contracts were green before orientation and remain important:

- BPMN DI is authoritative rendered geometry.
- Atelier calculates editing/auto-layout geometry; Bloc projects it.
- `CPAtelierLaneLayout` owns Lane minimum and recursive LaneSet reflow policy.
- Horizontal Lane minimum height is 140.
- Vertical Lane minimum width introduced in AT is 140.
- Lane deletion removes Lane/Lane DI but preserves referenced FlowNodes.
- Lane membership is partition metadata, not FlowNode ownership.
- FlowNodes move with their Lane when Pool/Lane geometry moves.
- committed SequenceFlow waypoints move coherently with those nodes.
- live resize preview uses proposed Lane bounds, FlowNode bounds and edge waypoints as one coherent preview snapshot.
- external node labels and connection labels follow the same proposed geometry during resize.
- `CPAtelierResizeParticipantShape>>endpointDeltaFrom:to:` is required by its superclass and must not be deleted as “dead code.”

Canonical horizontal examples include `horizontalPoolLaneEditingRegression` and `horizontalPoolLaneMutationRegression`.

## I. Structural/package integrity rules

Before sending any Process archive, audit at least:

- every `.class.st` filename matches declared class `#name`,
- declared `#package` matches package directory,
- no duplicate class definitions,
- no orphan Tonel `{ #category : ... }` sections,
- no accidental production BVC-BPM-GT dependency on BVC-BPM-Atelier policy classes,
- required superclass hooks such as `endpointDeltaFrom:to:` remain present,
- no collection ordinal selectors beyond `ninth`,
- no accidental overwrite of one class file with another class declaration.

Historical reason: patches AB/AC were corrupted by writing `CPProcessVisualElementExamples` content into `CPProcessLaneContext.class.st`; AK contained a duplicate Tonel category marker. These failures must not recur.

## J. Foundation/GT design rules to preserve

- GT examples use `self assert:`; these example classes are not `TestCase` subclasses and do not support `deny:`.
- Parenthesize boolean keyword expressions under `assert:` where parser ambiguity can create selectors such as `#assert:identityIncludes:`.
- Never add/modify GT framework code without explicit user authorization, source evidence and design justification.
- Avoid `respondsTo:` compatibility probing.
- Avoid arbitrary symbol-dispatch configuration APIs.
- `beOrdered` is for to-many relation descriptions only, never `MAToOneRelationDescription`.
- Process classes use `CP` prefix.
- Source claims must distinguish exact source fact, user runtime evidence and inference.
- Motion is the exclusive animation system.

## K. Recommended immediate continuation

1. Load/test `ProcessSep11-0640-patchBE-label-counterrotation-space-fix.zip` on top of the same Foundation grouped-buttons/Motion environment.
2. Visually test both Horizontal→Vertical and Vertical→Horizontal with:
   - Start Event external label,
   - End Event external label,
   - Gateway external label,
   - labelled SequenceFlows on different segment orientations.
3. The acceptance criterion is strict: each external node label stays on its intended screen-space side of the upright node for the entire rotation, and every connection label remains continuously attached to its intended path placement. There must be no end-of-Motion jump when DI refresh occurs.
4. If BE fails, instrument actual composed positions through Motion progress instead of applying another guessed sign/axis correction.
5. Once labels are seamless, run the canonical horizontal regressions plus the orientation round-trip regressions before continuing vertical creation/insertion behavior.

---

# CURRENT CONTINUATION SNAPSHOT — 10 September 2026, ~21:32 Sydney

This section supersedes the implementation-status and continuation advice in the older handover below. The older material is retained because it contains the original source audit, normative references, class map and historical findings. Do **not** treat its old `CPProcess>>diagram` / Process-root transaction descriptions as the current target architecture.

## A. The singular refactor goal

The work in this chat has had one architectural goal:

> Move Catalyst Process editing from a Process-rooted transaction/depiction model, where `CPProcess>>diagram` and Process-local Collaboration discovery act as authority, to a `CPDefinitions`-rooted editing session with an explicit semantic Process focus and an explicit selected BPMN depiction.

This goal is still the boundary. The chat did **not** intentionally start the later Atelier features (lane/pool reorder, smooth animated layout, stable visual identity, general Motion integration, XML interchange, auto-layout, etc.). Lane dragging became a blocker because exercising the newly document-rooted Pool/Lane path exposed a pre-existing, fragile Bloc projection/coordinate model.

The important distinction for the next chat is:

- **BPMN model and BPMN DI must conform to BPMN.** Semantic containment, Lane references, diagram ownership and persisted plane-relative geometry are domain/interchange concerns.
- **Bloc is a projection.** It does not need to mimic BPMN ownership. Its hierarchy should be chosen to support excellent interaction, staging, reordering, animation, clipping, focus, selection and smooth shape changes.
- The projection contract must nevertheless be exact: changing Bloc parentage must not silently change BPMN meaning or BPMN-DI position.

## B. Which source to resume from

### Current recovered checkout

Source inspection after the recovery found clean checkouts at Process `afa2394a53ab62cfce5202c1875c86209156b92b` (`recover`) and Foundation `1d801e7` (`p11`). The Process recovery commit removes the Phase 22 Lane hierarchy operation and restores the earlier coordinate paths. Start by verifying this checkout against the connected image; do not automatically replace it with an archive. Archive identity has not been proven by a byte-for-byte comparison. No new runtime verification was possible in the subsequent cleanup session because GT MCP tools were unavailable.

### Historical recommended recovery baseline: Phase 21

Use **`ProcessSep10-conformance-phase21.zip`** as the conservative code baseline for the next chat.

Phase 21 contains the document-root/session work plus the beginning of legacy fixture migration. Its Phase 21 production behavior is essentially the last point before the coordinate/projection experiments in Phases 21-coordinate and 22. At that baseline:

- ordinary node movement worked;
- ordinary palette drag worked;
- connecting nodes worked;
- Pool creation worked after the document-context wiring fix;
- Lane creation worked;
- the known unresolved bug was cross-Lane dragging / projection coordinates, especially a displacement approximately equal to Lane-header depth.

Do **not** take the latest Phase 22 projection-origin build as a new baseline. By the end of this chat it was visibly worse: even same-Lane drags could reposition nodes and connector labels were moving incorrectly.

### Builds after Phase 21 that should be treated as experiments, not accepted baseline

The following builds contain useful evidence but should not be carried forward wholesale:

- `ProcessSep10-conformance-phase21-coordinate-fix.zip`
- `ProcessSep10-conformance-phase21-lane-coordinate-fix.zip` — caused very large (~1000 px+) displacements; explicitly rolled back.
- `ProcessSep10-conformance-phase21-lane-coordinate-rollback.zip`
- `ProcessSep10-conformance-phase22-lane-projection-stability.zip`
- `ProcessSep10-conformance-phase22-example-fix.zip`
- `ProcessSep10-conformance-phase22-projection-coordinate-fix.zip`
- `ProcessSep10-conformance-phase22-projection-origin-fix.zip` — latest experimental state; **known runtime-broken**.

Do not assume every idea in Phase 22 is wrong. In particular, the deeper-Lane membership and DI-based Lane-target ideas may be useful. They need to be re-derived and tested independently from the failed coordinate changes.

## C. Architecture established by the refactor

The intended transaction/editing structure now is:

```text
CPDefinitions                              transaction/document authority
  rootElements ordered
    CPProcess                             semantic focus
    CPCollaboration                      sibling root element
  diagrams ordered
    CPDiagram depicting Process          possible selected depiction
    CPDiagram depicting Collaboration    independent depiction

CPProcessAtelierSession
  rootMemento                            Definitions memento
  processMemento                         child memento for semantic focus
  diagramContext                         explicitly selected depiction
  documentContext                        CPDefinitionsMementoContext
  collaborationContext                   resolved from Definitions when present
```

Critical invariant: **the session's selected `diagramContext` and the Collaboration's `diagramContext` are separate concepts.** If the selected diagram depicts the Collaboration they can refer to the same underlying diagram, but code must not infer that they are always the same or borrow one as the other.

Important classes introduced/refined during this refactor include:

- `CPDefinitions`
- `CPDefinitionsMementoContext`
- `CPProcessAtelierSession`
- `CPDiagramMementoContext`
- `CPProcessCollaborationContext`
- `CPProcessAtelierDiagramEditing`
- `CPProcessAtelierConfiguration`
- `CPProcessPresentation`
- `CPProcessVisualElement`

Foundation gained an explicit transaction-root seam on presentations: `CFMaPresentation>>transactionMemento`. Ordinary Detail/form editing still uses the visible object's memento, while toolbar transaction actions and Escape/reset can target the shared document transaction root.

## D. What the refactor changed, by phase

The original plan had fewer than ten conceptual steps. The phase count reached 22 because each small green checkpoint and regression repair was numbered separately. Do not read “22 phases” as 22 new features.

### Phases 1–8 — model/DI/context groundwork

- Introduced `CPDefinitions` as the document concept and added ordered `rootElements` / `diagrams`.
- Added/expanded faithful DI structures (`CPDiagram`, `CPPlane`, `CPShape`, `CPEdge`, labels/styles/font structures) toward BPMN DI shape rather than the earlier simplified Process-owned depiction concept.
- Added `laneSets` to `CPSubProcess` as a FlowElementsContainer concern.
- Corrected MessageFlow endpoint typing toward InteractionNode-compatible domain objects.
- Fixed imported identifier preservation in Foundation identity handling.
- Introduced `CPDiagramMementoContext` and migrated operations toward explicit diagram context instead of rediscovering a raw diagram description from Process state.

### Phases 9–14 — document-rooted editing session and Collaboration ownership

- Introduced `CPProcessAtelierSession` carrying transaction/document/process/depiction context.
- Introduced `CPDefinitionsMementoContext`.
- Added Definitions-rooted session construction.
- Added Foundation `transactionMemento` so a nested presentation can commit/reset the shared root transaction without making the root object the form's visible model.
- Moved canonical Collaboration/Participant/MessageFlow creation toward `CPDefinitions` ownership.
- First Pool creation can stage a new `CPCollaboration` root element plus a Collaboration diagram and stage `CPProcess>>definitionalCollaborationRef`.
- Participant, MessageFlow and Lane-related operations were threaded with explicit Collaboration/document context rather than assuming Collaboration is a Process child.

### Phases 15–18 — entry-path and live-presentation integration

- Added canonical `CPDefinitions>>asAtelierForProcess:diagram:` entry.
- `CPProcess>>asAtelier` had to remain as a compatibility/user entry because removing it caused the Process palette to disappear through Foundation's generic path.
- Definitions convenience entry gained sole-relevant-depiction selection and ambiguity rejection.
- Phase 18 changed compatibility `CPProcess>>asAtelier` to create a temporary Definitions document so even the compatibility path uses a Definitions-rooted transaction.
- A major Phase 18 live bug was found: renderer code was rebuilding DI context through legacy `CPProcess>>diagram` while operations wrote the Definitions-owned diagram memento. This made node movement, palette drops and connects appear inert.
- The Phase 18 interaction fix added explicit `diagramContext` to `CPProcessPresentation` / `CPProcessVisualElement` and inherited it into nested visuals. User runtime confirmation: ordinary move, palette drag and connect worked again.

### Phases 19–20 — first Pool/Lane transition and depiction separation

- Pool/Lane remained broken because after the first Pool creation the presentation still resolved Collaboration through the old Process-rooted path.
- `CPProcessCollaborationContext` was given a document-aware resolver using staged `CPProcess>>definitionalCollaborationRef`, Definitions root elements and Definitions-owned diagrams.
- Session/editing/presentation Collaboration context became dynamically resolvable because before first Pool the Collaboration legitimately does not exist, while the operation can create it during the session.
- A further live bug was found: `CPProcessAtelierConfiguration` did not actually pass `session documentContext` into `CPProcessPresentation`. Adding that wiring made first Pool -> Lane interaction work. User said “looks good”.
- Phase 20 removed the constructor that let document-rooted Collaboration context borrow the session's selected diagram context. Collaboration now resolves its own depiction from Definitions. This locks in the selected-depiction vs Collaboration-depiction separation.

### Phase 21 — begin final legacy fixture migration

- Converted the two editing-session examples that explicitly asserted Process-rooted session semantics to Definitions-rooted construction.
- Production behavior was intentionally left alone.
- The remaining legacy `CPProcessAtelierSession forProcessMemento:` callers were reportedly confined to shared legacy fixture helpers, to be migrated before removing that constructor.

### Phase 21-coordinate / Phase 22 — projection investigation; NOT COMPLETE

User then reported cross-Lane drag instability. The sequence of experiments did not produce a reliable fix and should be treated as investigation evidence, not completed implementation.

## E. Exact current runtime failure evidence

These observations are user-reproduced in the live editor and are more authoritative than passing examples for interaction behavior.

### Initial symptom after Phase 21

- Dragging nodes between Lanes caused a release-time reposition.
- Offset looked approximately like one Lane header width/depth (~30 px).
- Nodes could disappear during cross-Lane dragging.

### More precise observation during investigation

User identified that during a drag, **node, external label and connection anchor appeared to use different coordinate systems**:

- connection anchor appeared correct;
- node was wrong during drag but could reposition correctly on release;
- label was wrong during drag and remained wrong after release.

This is strong evidence of multiple projection-coordinate paths, not one bad persisted BPMN-DI value.

### Failed experiment: native global/local replacement

One attempt replaced the Lane-body manual mapping with direct Bloc global/local conversion. Result: catastrophic displacement, often 1000+ px, and even same-Lane dragging broke. This was explicitly rolled back. Conclusion: the relevant elements are not safely interchangeable through that world-coordinate conversion at the point it was used; layout/refresh/sibling projection structure matters.

### Phase 22 nested Lane / target changes

A Phase 22 experiment:

- made staged Lane lookup choose the deepest referenced Lane in the rendered hierarchy;
- constrained projection host lookup to the rendered first top-level LaneSet;
- chose Lane target using staged Lane BPMNShape bounds rather than `bodyHost geometryBoundsInSpace`;
- introduced `CPAtelierAssignFlowNodeToLaneHierarchy` so moving into a nested Lane can stage the Lane path rather than only one sibling partition.

An example initially failed only because `self assert: ... identityIncludes:` was parsed as `#assert:identityIncludes:`; the example was fixed with parentheses. This says nothing by itself about the runtime projection behavior.

### Failed transient-proxy / label experiment

Another experiment seeded drag proxies from the live projected source element and tried to use live projected geometry for labels. Newly built event labels then stacked at the top-left because their source shape did not yet have reliable world geometry during build.

### Latest experiment: projection-origin mapping

The latest experiment tried to compute a Lane body's projected origin from its live `bodyHost` bounds rather than reconstructing it as `lane DI origin + laneHeaderWidth`.

Latest user runtime result (screenshot at ~21:29):

- things reposition even **without** moving between Lanes;
- connector labels are now broken and reposition;
- therefore the latest Phase 22 projection-origin build is not acceptable.

This is the stopping point of the chat.

## F. What is proven vs what is still hypothesis in the Lane problem

### Proven by source/runtime

1. The current Bloc renderer structurally nests FlowNodes under Lane `bodyHost`s in at least the Phase 21 design (`presentationHostForFlowNode:`).
2. The Lane projection has a visual header/body structure with a fixed header-width concept.
3. BPMN-DI shape bounds are plane-relative by BPMN DI definition; visual Bloc parentage is a separate concern.
4. Cross-Lane movement changes staged Lane membership and refresh can rebuild/reparent visuals.
5. `CPProcessVisualElement>>refresh` historically rebuilds live visual elements rather than preserving their identity.
6. There are multiple coordinate consumers: shape placement, transient drag proxy, external labels, edge/anchor geometry, connector labels, Lane hit/target logic.
7. These consumers were demonstrably not all in the same coordinate space during the failed runtime runs.

### Do NOT treat these as proven root causes yet

- “subtracting exactly one header is the bug” — the symptom matched header depth, but attempts to remove/rederive that offset exposed larger inconsistencies.
- “nested Bloc parentage is wrong” — not established. Nested Bloc structure may be desirable for future animated Lane/Pool interactions.
- “FlowNodes must be flat on `diagramLayer` because bpmn-js does it” — false as a requirement. bpmn-js is comparative evidence, not Catalyst's projection specification.
- “Phase 22 hierarchy membership operation is correct” — plausible, but it has not had sufficient runtime/lifecycle verification and should not be accepted merely because its focused example is green.

## G. Projection design requirement for future Atelier work

The user explicitly wants the Bloc projection to be capable of later Atelier behaviors:

- stage and visualize changes before commit;
- reorder Lanes within a Pool;
- reorder Pools within a diagram;
- smoothly animate resulting shape/layout changes;
- support joyful, coherent interaction rather than a minimal static BPMN renderer.

Therefore do **not** “fix” the Lane bug by flattening or simplifying Bloc purely to resemble BPMN ownership unless source/interaction evidence shows that projection is actually the best long-term structure.

A good projection architecture must make these boundaries explicit:

```text
BPMN semantics             authoritative meaning/ownership/references
BPMN DI                    authoritative persisted plane geometry
       ↓
projection mapping         explicit, testable conversion boundary
       ↓
Bloc hierarchy             interaction/layout/animation structure
       ↓
gestures
       ↓
projection -> DI/domain    explicit assessed operations
```

A drag proxy already exists in the recovered source: `CPProcessDragPresentation>>beginIn:shapeAt:labelAt:` hides the real shape and external label, adds inert proxies to the root diagram, mirrors drag deltas, and restores the originals on finish. The real shape stays under its original parent and supplies live connection geometry. This is not reparenting the original shape through a portal. The existing proxy must be included in the coordinate investigation rather than implemented again.

## H. Recommended first investigation in the next chat

Do not start with another coordinate patch. Start from Phase 21 and make the spaces observable.

1. Verify the recovered checkout against the connected GT image and reproduce the original ~header-depth cross-Lane problem before changing code. Compare the Phase 21 archive only if needed to establish provenance; do not load it automatically over the recovery.
2. Inspect these methods together, not individually:
   - `CPProcessVisualElement>>presentationHostForFlowNode:`
   - `CPProcessVisualElement>>diagramPoint:localToPresentationHost:`
   - `CPProcessVisualElement>>diagramBoundsForElement:`
   - `CPProcessVisualElement>>rootDiagramPointForLocalPoint:`
   - `CPProcessVisualElement>>diagramPointForGlobalPoint:`
   - `CPProcessVisualElement>>installPositioningFrom:moving:for:`
   - external FlowNode label creation/positioning
   - connector/edge label positioning
   - anchor positioning and edge refresh
   - `CPLaneShapeElement` body/header layout and clipping
   - `CPProcessVisualElement>>refresh`
3. For one drag, record at drag start, each update, release, and post-refresh:
   - persisted/staged BPMN-DI bounds;
   - source and target Lane DI bounds;
   - actual Bloc parent of the shape;
   - shape local position;
   - shape position converted into the Process diagram projection;
   - proxy position;
   - external label position;
   - anchor position;
   - edge label position;
   - Lane bodyHost origin and nesting depth.
4. Establish **one named projection-coordinate contract** for each conversion rather than making ad-hoc global/local calls or subtracting header values in unrelated methods.
5. Only after the numbers explain the original 30 px displacement should code change.
6. Verify, manually and with focused examples: same Lane repeated, sibling Lane A↔B repeated, outer→nested, nested→outer, multiple nesting depths, connected nodes, event labels, connector labels, boundary events, commit and reset.
7. Keep semantic Lane-membership cleanup separate from projection-coordinate cleanup so a failure can be localized.

## I. Remaining work to finish the original Definitions-root refactor

### Source trace from the recovered checkout

Cleanup follow-up: GT MCP became available again. Source spot checks matched the recovered Lane conversion and Definitions session constructor. `laneFlowNodeUsesLaneBodyAsPresentationHost`, `definitionsRootedVisualUsesSelectedDiagramMemento`, and `documentRootedFirstPoolThenLaneUsesCreatedCollaboration` passed in the connected image.

A bounded drag-event reproduction proved that single-node release persisted the preceding drag event's position instead of the final pointer delta. `CPProcessVisualElement>>installPositioningFrom:moving:for:` now uses its supplied `proposedBounds` on release. `documentRootedLaneDragUsesFinalPointerDelta` failed before this fix and passed after it. `documentRootedRepeatedLaneDragsPreserveProjectionAndReset` also passed, covering repeated same/sibling-Lane drags, live-vs-staged bounds, external event-label position, and document-root reset. Both use the new Definitions-rooted `documentRootedLaneDragFixture`, with separate Process and Collaboration diagrams and a connected event/task pair. The fix and examples are compiled through GT MCP and saved as uncommitted source changes.

This is a verified release-position fix, not proof that the original reported cross-Lane offset is fully resolved. The consistent two-Lane fixture reproduced no header-offset error after layout. Full suites, manual live gestures, nested Lane projection, edge-label continuity and commit coverage for this new fixture remain outstanding. Legacy ownership/fixture removal has not started. Continue from this small patch rather than claiming the whole cleanup is complete.

The following source findings describe the recovered baseline before that release fix:

- `CPProcessVisualElement>>diagramPoint:localToPresentationHost:` places Lane-hosted nodes by subtracting staged Lane origin plus one 30-pixel header. `CPLaneShapeElement` obtains its actual body origin from Bloc frame layout, while `CPLaneSetVisualElement` and the enclosing presentation determine its actual size and position.
- `CPProcessVisualElement>>diagramBoundsForElement:` maps both live corners through global coordinates into the diagram presentation parent. The critical invariant is that placement followed by this inverse conversion returns the original staged DI bounds after layout. For a translation-only host, this requires the body's actual origin in diagram coordinates to equal the assumed Lane origin plus header. Measure both sides; do not assume their equality or the cause of any discrepancy.
- `CPProcessVisualElementExamples>>laneFlowNodeUsesLaneBodyAsPresentationHost` checks parent identity and the subtraction formula. It does not check that inverse conversion after live layout reproduces the staged bounds. A passing result therefore does not establish projection correctness.
- `CPProcessShapeElement>>installPositioningFrom:stagedBounds:dragStarted:dragStartPosition:dragged:dragEnded:` computes a final pointer delta and proposed bounds on `BlDragEndEvent`, but does not relocate the real shape to that final pointer position. The single-node callback in `CPProcessVisualElement>>installPositioningFrom:moving:for:` instead reads live shape bounds and ignores the supplied proposed bounds. Test a release position different from the last drag event. This discrepancy is separate from the unproven Lane-header root cause.
- Drag proxies start from staged shape bounds converted through `rootDiagramPointForLocalPoint:`. External FlowNode labels start directly from DI bounds; live edge labels use live endpoint bounds. Capture each path in the same laid-out diagram space during the reproduction.

### Legacy consumer inventory

The exact `CPProcessAtelierSession forProcessMemento:` sends are confined to `CPProcessAtelierExamples>>diagramEditingForMemento:` and `>>diagramContextForMemento:`. Their callers and fixtures still construct Process-rooted mementos, read `#diagram`, and often commit/reset that Process root. Migrate the fixture transaction and its consumers, not just the two helper implementations.

Production compatibility paths still include:

- `CPProcess>>asAtelier`, which creates temporary Definitions but obtains its selected depiction through `self diagram`.
- `CPProcessVisualElement>>memento:flowContainer:` and `>>refresh`, which discover a Process diagram when no explicit context is supplied.
- `CPAtelierResizeParticipantShape>>stagedProcessDiagramContext`, which still falls back to the Process diagram description.
- `CPProcessCollaborationContext class>>inRootMemento:`, used as a fallback by Process/Collaboration presentations and Participant, MessageFlow, Lane and diagram-removal operations.
- `CPAtelierCreateParticipant>>applyLegacyAssessment:` and the corresponding legacy removal path, which retain Process-owned Collaboration state.
- Both `CPProcess` and `CPCollaboration` still expose `diagram`, `diagram:` and `diagramDescription`.

When removing these paths, distinguish the legitimate semantic Process child memento from the obsolete transaction authority. Flow-container and Lane contexts may still need the Process child. They must not be mechanically redirected to a Definitions model. Preserve the independently selected session depiction and Collaboration depiction. Resolve compatibility navigation explicitly before deleting its only current depiction source.

Once the projection is back to a trustworthy baseline, the remaining refactor cleanup was intended to be narrow:

1. Migrate the shared legacy Process-rooted fixture helpers to Definitions-rooted sessions/transactions.
2. Remove `CPProcessAtelierSession class >> forProcessMemento:` when there are no production/example consumers.
3. Remove the legacy `CPProcess>>diagram` ownership path and its Magritte description **only after** every real consumer has moved to explicit Definitions-owned diagrams / `CPDiagramMementoContext`.
4. Remove Process-rooted Collaboration fallback paths that exist solely for old fixtures/compatibility, after proving the compatibility entry remains functional.
5. Run the relevant full Process/Foundation example groups and manually verify palette, move, connect, first Pool, first Lane, commit/reset.
6. Stop and reassess. Do not automatically begin the broader BPMN-DI coordinate/interchange project or Atelier reorder/animation work as part of this refactor.

## J. Source and behavioral rules carried forward

- GT examples here are GT examples, not `TestCase` subclasses. Do not use `deny:`; use `self assert: condition not`.
- Parenthesize boolean message expressions under `assert:` where keyword parsing can otherwise form selectors such as `#assert:identityIncludes:`.
- `beOrdered` belongs on to-many relation descriptions where ordering is domain-significant; never add it to `MAToOneRelationDescription`.
- Avoid `respondsTo:`, protocol probing and class-switch compatibility seams. If callers cannot rely on an explicit collaborator contract, fix the abstraction.
- Avoid arbitrary symbol-dispatch configuration APIs.
- Process classes use `CP` prefix, not `CPBPMN*`.
- Do not modify GT/dependency framework source without explicit user authorization and evidence.
- Source claims require exact source proof; distinguish proven source fact, runtime observation, and inference.
- Preserve BPMN semantics separately from Bloc projection choices.

## K. Important artifacts from this chat

Conservative continuation baseline:

- `ProcessSep10-conformance-phase21.zip`
- `ProcessSep10-conformance-phase21.patch`

Foundation document-transaction change:

- `FoundationSep10-transaction-root-phase11.zip`
- `FoundationSep10-phase11.patch`

Useful earlier accepted Process checkpoints:

- `ProcessSep10-conformance-phase18-interaction-fix.zip` — restored move/drop/connect after explicit diagram context wiring.
- `ProcessSep10-conformance-phase19-interaction-fix.zip` — supplied `documentContext` to presentation, restoring first Pool/Lane transition.
- `ProcessSep10-conformance-phase20.zip` — removed selected-depiction borrowing from document-rooted Collaboration context.

Investigation-only Phase 22 artifacts are listed in section B and should not be loaded as accepted baseline.

Reference sources:

- `formal-11-01-03(6).pdf` — BPMN 2.0 normative specification.
- `bpmn-js-18.16.0(6).zip` — behavioral/architecture comparison only.
- `Foundation-Sep10-0925.zip`
- `GTUI(20260909-232601).zip`
- original `FOUNDATION-ATELIER-PROCESS-AI-HANDOVER.md`
- `Foundation-Atelier-Project-Definition-v3(6).docx`

## L. Bottom line for the next chat

The document-root/session refactor is substantially established, but it should **not** be called finished yet because legacy fixture/compatibility cleanup remains. The immediate blocker is an older Lane/Bloc projection coordinate problem exposed by the now-working document-rooted Pool/Lane interaction path.

Do not continue from the visibly broken Phase 22 projection-origin experiment. Return to Phase 21, reproduce the smaller original bug, instrument the projection spaces, and derive the mapping before altering it. Preserve the freedom to design a sophisticated nested Bloc projection suitable for staged reorder and smooth animation; BPMN conformance belongs to the semantic/DI layers, not to copying BPMN ownership into Bloc.

---

# HISTORICAL SOURCE-AUDIT HANDOVER (retained for evidence and class map)

# Foundation Atelier and Process AI handover

Source audit and working context, 10 September 2026

Canonical source: `CatalystProcess/process/FOUNDATION-ATELIER-PROCESS-AI-HANDOVER.md`. The September 10 Word handover is the matching reading copy.

## 1 Read this first

This is the working handover for an AI chat continuing Foundation, Atelier and the Catalyst Process BPMN editor. Its purpose is to make the next chat productive without repeating the earlier investigations or inheriting incorrect implementation claims. The product goal is a BPMN diagram editor that emerges naturally from a BPM model, edits that model directly, and feels coherent and enjoyable inside an Atelier workspace.

The implementation already has a substantial native editor: BPMN semantic objects and diagram objects, Foundation mementos, typed diagram-editing delegation, assessed operations, shared selection, nested Sub-Processes, Pools, recursive Lanes, Boundary Events, labels and native scrolling. Several design promises remain incomplete. In particular, the current source does not establish automatic diagram derivation, a resizable Tree Pager details strip, stable visual identity across refresh, complete BPMN validation or BPMN XML interchange. See the findings rather than interpreting class presence or earlier green examples as completion.

This document supersedes the earlier Process handover's implementation-status statements and continuation plans. Foundation Atelier Project Definition v3 remains historical design intent; its CPProcessDesign-era client, fixed canvas, Tree Pager and Motion statements are not a description of the current CPProcess implementation. Historical archive names such as ProcessSep9-2522 identify provenance, not the checkout to load automatically.

Treat the user's current request as the task. A handover is context, not authorization to run every proposed action, change framework code, publish, or resume an old feature plan. Before changes, inspect current source and working-tree state. Preserve unrelated changes. The initial audit changed documentation only. A subsequent transaction-correctness change addresses F01 and F02; the other findings remain open.

Evidence labels used below:

- **Source confirmed:** directly established by named methods in the recorded checkout.
- **Runtime reproduced:** a specific result observed in the connected GT image during this audit.
- **Verification required:** plausible behavior or a product requirement that source reading alone does not establish.
- **Design goal:** desired behavior, not an assertion that it exists.

## 2 Snapshot and workspace

Workspace root: `/opt/git/BenjaVisionPro/gt-runtime-workspace`.

| Repository | Audited commit |
| --- | --- |
| CatalystProcess | `374d2be1a29f26c35531426fcb194d60fff13c95` |
| CatalystFoundation | `3bb7e43aa50bd45fff72931dad443034d7a442bb` |
| CatalystRuntime | `11405c3e3d9fcdc0289d8e620e7c67277941b3ae` |

These are the original audit commits. The transaction follow-up starts from Process documentation commit `413972478ede636295bd8cd5ce12f5a422495bea` and the same Foundation commit; its fixes are currently uncommitted working-tree changes. Earlier revisions were loaded through GT MCP; the final status-routing compilation timed out, so final source/image parity is unconfirmed. Process and Foundation source files were clean relative to the audit commits at audit start. Process had a pre-existing deleted September 9 handover and untracked September 10 handover and diagram.svg. The workspace itself already had unrelated changes, including config, submodule pointers and an untracked Process directory. Do not assume Process is registered as a workspace submodule merely because it is an independent Git repository.

Use each child repository's own Git status and history. The workspace runtime skill requires child-repository commits before submodule-pointer updates where applicable. Dependencies under `deps/` are inspect-only without explicit user authorization. The transaction follow-up changes CatalystFoundation child-memento lifecycle and CatalystProcess; no deps/ framework source was changed.

The workspace graphify graph was queried but did not provide useful current Process/Atelier coverage. It mainly returned Foundation Motion material. Treat it as a navigation aid with limited coverage, not a substitute for current Tonel source.

Reference inputs are the previous Process handover, Foundation Atelier Project Definition v3, `/Users/jupiter/Downloads/formal-11-01-03.pdf` and `/Users/jupiter/Downloads/bpmn-js-18.16.0.zip`. The PDF is BPMN 2.0, formal/2011-01-03, January 2011, 538 PDF pages. Printed page numbers differ from PDF page numbers. OMG identifies it as the normative document at https://www.omg.org/spec/BPMN/2.0. The bpmn-js archive was read as a behavioral and architecture comparison, not incorporated into Catalyst.

## 3 Where responsibilities actually live

**Magritte** supplies executable descriptions: accessors, accepted relation classes, cardinality, ordering flags, required/read-only state, references, grouping and value validation. Read and write through the descriptions belonging to the active memento. An OrderedCollection does not imply that its Magritte description is ordered; MAToManyRelationDescription defaults to unordered.

**GT Magritte** supplies observable GtMagritteValue state and validation futures. GtMagritteMemento reads current staged values; write:using: replaces an observable value and initiates validation. Its source explicitly requires writes on the UI thread. commit pushes changed visible, non-read-only descriptions and resets the cache. A programmatic staged write to a read-only field is therefore not a promise that commit persists it.

**Foundation Magritte** extends this with CFMaMemento child editing state and reusable presentations. Child mementos are keyed by relation description and object identity. commit and reset recurse; detached children support remove/replace reset; same-parent relation transfers can re-key children. Cross-parent transfers now use an explicit common-root reparenting protocol with a caller-supplied owner description, preserving the original child memento and all descendants. The root records ownership changes for reset and commits surviving children's staged owner links before either parent writes membership collections. CFMaViewModel asks the memento's Magritte container for blocPresentationStencil. Foundation owns Detail, relation editing, editable-label infrastructure, presentation configuration and the Phlow navigation adapter.

**Atelier** wraps the Foundation-selected form with configured supply and composition behavior. CFAtelierViewModel subclasses CFMaViewModel; CFAtelierElement owns the floating palette and Catalyst theme context. CFAtelierOperation>>apply assesses immediately before applying an accepted assessment. An operation is one assessed editing intention, but this base class does not implement rollback after an arbitrary exception between writes, database transactions or undo history. Do not call every multi-write operation unconditionally atomic.

**Process** owns BPMN objects, DI-like diagram data, topology and connection rules, staged Process/Collaboration/Lane contexts, BPM-specific operations and presentation. Shared staged-state contexts are in BVC-BPM-Magritte, so GT and Atelier can both depend on them. BVC-BPM-GT defines CPProcessDiagramEditing and its read-only implementation; BVC-BPM-Atelier provides CPProcessAtelierDiagramEditing and concrete operations.

**Bloc and Brick** supply the real scene graph, layout, clipping, event propagation, focus, cursors and scroll panes. **Phlow** supplies object-oriented views and navigation. **Catalyst Motion** animates transitions between authoritative layout states; it does not make transforms or preview positions authoritative model state. **Catalyst Theme** supplies surfaces, borders, typography and interaction colors; CFAtelierElement currently installs CgtDetailLightTheme.

Source entry points: CFMaMemento, CFMaViewModel, CFMaPresentation, CFMaDetailPresentation, CFMaPhlowNavigation, CFEditableLabel, CFAtelierViewModel, CFAtelierElement, CFAtelierOperation and CFMotionLayoutTransaction. Package locations are indexed in section 13.

## 4 Entry paths and transaction lifecycle

The ordinary entry is Object>>asAtelier, returning CFAtelierViewModel forObject:. Object>>gtAtelierFor: adds the Phlow Atelier view for objects with Magritte descriptions. Object>>asAtelierWith: applies a configuration.

The Process specialization is CPProcess>>asAtelier in BVC-BPM-Atelier. It constructs CFMaMemento model: self, CPProcessAtelierConfiguration forProcessMemento:, and CFAtelierViewModel forObject:memento:. CPProcess>>descriptionContainerProcessPresentation: in BVC-BPM-GT selects CPProcessPresentation. The current Process root uses ordinary CFMaMemento; do not describe it as the old CPProcessDesignMemento lifecycle from Atelier v3.

CFMaViewModel>>initializeForm:forMemento:includeImplicitActions: creates the form container, selects the presentation through blocPresentationStencil, supplies the memento and actions, applies presentation configuration, then builds. Atelier decorates this path with generic relation-operation hooks and the client configuration. It does not independently choose a diagram renderer.

CPProcessAtelierConfiguration supplies provider-backed palette items and installs CPProcessAtelierDiagramEditing on the Process presentation. The palette currently offers Pool, Start event, End event, Intermediate event, Boundary event, Task, Call activity, Sub-process and Gateway. Task and Gateway are also contextual append candidates. The exact Pool palette item is retained for contextual Lane behavior.

CPProcessPresentation composes a diagram BrScrollPane and a 380-wide Detail BrScrollPane. It uses the root memento for Process rendering and resolves selected FlowNodes, Lanes and Collaboration members to their child mementos for CFMaDetailPresentation. Detail is blank when there is no sole selected DI object. It is not currently an embedded GtTreePager and has no BrResizer in this construction path.

CFAtelierEmptyViewModel is a separate empty-root path. It adopts an object with Magritte descriptions and builds CFAtelierViewModel directly, applying configured editing hooks. It does not call the adopted object's specialized asAtelier. Process-specific configuration therefore must not be assumed to appear automatically through empty-root adoption. The implementation deliberately uses a drop-target/adoption callback because root adoption changes editor context rather than a relation; the earlier description of a dedicated assessed root operation overstates this path.

Foundation's generic CFAtelierMove requires sourceMemento == destinationMemento. A shared root somewhere above two different child mementos is not sufficient. This restriction is deliberate in the current implementation. Process cross-container transfer uses its own operations and the separate common-root reparenting protocol. This does not relax CFAtelierMove's same-parent restriction.

## 5 BPM model and depiction model

The active editor model is CPProcess, not CPProcessDesign. CPProcess has flowElements, laneSets, diagram and definitionalCollaborationRef. CPFlowNode adds incoming/outgoing SequenceFlow relations to CPFlowElement. CPActivity is the base of tasks, Call Activity and Sub-Process. CPSequenceFlow owns sourceRef and targetRef; its committed setters maintain inverse node collections. Staged editing must not use those setters on committed objects as a preview mechanism.

CPSubProcess is an Activity and a flowElements container. It does not currently have the full BPMN SubProcess metamodel. Its concrete variants are CPNoneSubProcess, CPLoopSubProcess, CPMultiInstanceSubProcess, CPCompensationSubProcess and CPAdHocSubProcess. CPCallActivity references CPProcess through calledElement; Global Tasks are not modeled.

CPCollaboration owns Participants, MessageFlows and a diagram. CPParticipant may reference a Process; the second Pool created by the current operation defaults to a black box. The editor centers on one root Process and its definitional Collaboration, not an unrestricted collection of independently editable Process roots. Removing its hosted Participant while other Pools remain is intentionally rejected by an existing example.

CPLaneSet owns ordered Lane objects in its collection. CPLane references FlowNodes and can own a child LaneSet. Lane membership is distinct from flow-container ownership. A node can participate in independent LaneSet partitions in the semantic model. The renderer currently only builds the first top-level LaneSet. Lanes inside Sub-Processes are not implemented by the current CPSubProcess/root-Lane-context path.

CPBoundaryEvent owns attachedToRef, cancelActivity and eventDefinitions. Its current type menu exposes Timer, Error, Message, Escalation and Conditional definitions. Rendering distinguishes interrupting and non-interrupting rings. The model is not a complete EventDefinition/configuration system.

CPDiagram is a simplified diagram/plane carrier with modelElement and elements. CPShape has modelElement, bounds and isExpanded. CPEdge has waypoints and path-relative label-placement state. CPDiagramSelection keeps an ordered collection of CPShape/CPEdge identities; semantic identity and visual-element identity are separate.

The BPMN specification separates semantics from depiction. BPMNShape objects are directly owned by a BPMNPlane even when they look nested; exported bounds are plane-relative positive coordinates (section 12.2.3.3, printed page 372, PDF page 402). Catalyst stores nested local coordinates and converts them for presentation. There is no audited BPMN XML interchange adapter that proves the required flattening/normalization. Call this a BPMN-oriented internal model, not demonstrated full BPMN-DI interchange conformance.

## 6 Staged context owners and operation flow

CPProcessFlowContainerContext resolves Process/Sub-Process flowElements from the root memento, discovers the containing context for a staged object, supplies child mementos and reads staged SequenceFlow endpoints and Boundary Event attachment. Fresh staged objects can have missing or stale committed container pointers. Use this context instead of inferring containment from those pointers.

CPDiagramMementoContext owns staged diagram elements, modelElement links, bounds, waypoints and diagram child-memento access. CPProcessCollaborationContext owns staged Collaboration participants, processRef, MessageFlows, endpoint ownership and its diagram context. CPProcessLaneContext owns staged top-level and child LaneSets, Lane mementos, sibling partitions and flowNodeRefs.

Typical operation flow is: gesture -> typed CPProcessDiagramEditing message -> CPProcessAtelierDiagramEditing resolves current DI and semantic context -> concrete CFAtelierOperation subclass -> assess current staged state -> apply accepted writes -> refresh presentation. Label text is a scalar field edit through GtMagritteBuilderUtility and the object's child memento, rather than a structural diagram operation.

Implemented operation families include node creation/append/insertion/replacement/removal; single/group geometry moves and resize; SequenceFlow connect/reconnect/removal; waypoints and edge-label placement; Sub-Process expansion; single and closed-group transfer; Participant create/move/resize/removal; MessageFlow connect/reconnect/removal; Boundary Event create/reattach/type change; Lane create/insert/child creation, assignment and combined node movement.

Closed-group transfer is already wired through CPProcessAtelierDiagramEditing>>moveShapes:toProcessHostedBy:waypointsByEdge: and CPProcessVisualElement>>moveGroupEntries:movedModelElements:delta:to:. It includes internal SequenceFlows and rejects flows crossing the transfer selection boundary. The typed adapter adds attached Boundary Events for moved Activities. Do not implement a duplicate transfer family based on the old handover's future-work statement. Nested editing-state preservation is addressed by F02. Lane cleanup remains a separate unresolved concern.

Selection is the user's explicit set. Each operation computes its own effective dependency set, such as incident flows and attached Boundary Events for removal. Do not replace selection with that effective set. A sole selected edge gets reconnect/bendpoint handles; multiple selection does not choose an arbitrary primary object. Pool selection and content selection have explicit mutual-exclusion handling.

## 7 Rendering and coordinates

CPProcessVisualElement coordinates rendering, staged lookups and interaction. CPProcessShapeElement owns a shape's local chrome, geometry, selection appearance, resize handles, ports, popups, labels and nested-process host. CPProcessEdgeVisual owns rendered segments, hit geometry, edge handles and label host. CPProcessEdgeLabelPath handles path-relative label geometry.

An expanded CPSubProcess shape hosts another CPProcessVisualElement through a clipped viewport. configureNestedProcessVisual: shares rootVisual, diagramSelection, callbacks, diagramEditing and palette items. The nested visual receives the same root memento plus its own flowContainer. There is one Atelier and palette, not one per Sub-Process. The parent shape is moved from its border; internal content uses the nested visual's own interactions.

Participants host Process presentation. CPLaneSetVisualElement uses vertical BlLinearLayout with Lane height weights. CPLaneShapeElement has a labelBand and bodyHost. Child LaneSets are real descendants of the parent Lane body. Lane-assigned node elements are actual children of the selected Lane bodyHost. Boundary Event elements are hosted by their attached Activity. Do not simulate these relationships merely by drawing overlapping rectangles.

Keep three coordinate contracts explicit: durable local Process/Sub-Process diagram coordinates; live Bloc parent-local coordinates; and top-level viewport/scroll coordinates. A Lane-hosted node and a connector preview can have different parents. CPProcessVisualElement>>diagramBoundsForElement: and CPCollaborationVisualElement>>liveCollaborationBoundsForFlowNode:inVisual: convert both corners via localPointToGlobal: and globalPointToLocal:. BlElement>>localPointToMine:fromChild: asserts an ancestor/descendant relationship and cannot be used directly across unrelated hosts.

Shape-aware docking belongs to CPProcessVisualElement>>dockingPointFor:bounds:toward:. Events use ellipse docking, Gateways diamond docking and Activities rectangular docking. Collaboration live FlowNode preview reuses this path. Visible connectors should meet object boundaries. Persisted waypoints and live drag geometry are separate contracts; a live preview correction must not silently replace durable authored geometry.

CPDiagramPlaneGeometry derives authored bounds/extent and normalization from staged DI. CPDiagramViewport computes per-axis slack = max(viewport extent - diagram extent, 0), and canvas extent = diagram extent + 2 * slack. The empty-diagram special case uses viewport extent and zero slack. Oversized content has no extra slack on that axis. Root Process/Collaboration own native scrolling; hosted/nested Process visuals do not create independent cameras. CPProcessPresentation preserves the authored-coordinate translation when switching Process/Collaboration presentation.

The full-canvas transparent drop surface must stay behind authored content; addPaletteDropSurface uses addChildFirst:. Current navigation is native wheel/trackpad scrolling, not click-drag canvas panning. The old 2200 by 1400 canvas claim is obsolete.

## 8 Interaction contracts

Palette target resolution should select the deepest eligible process visual. On blank Collaboration space Pool creates a Participant; on Lane body it inserts a sibling Lane; on Lane header it creates/appends within a child LaneSet. The same exact palette item drives these contextual meanings. CPCollaborationVisualElement>>acceptsParticipantPaletteDragItem: now permits the normal Participant path; the earlier second-Pool exclusion is absent in both the checkout and the two-method live-image spot check.

Labels use CFEditableLabel and staged Magritte text writes. beginEditingLabel: records the active editor, enables events, switches mode and defers focus by a Bloc task. finishEditingLabel: releases editor focus and queues focus back to the owning process visual. Memento-driven refresh is suppressed while a label is active. Delete/Backspace and Escape diagram handling is gated by event target == self so bubbled text-editing keys do not remove BPM objects. Enter should preserve selection. Diagram Escape cancels transient interaction and preserves persistent selection.

Native cursors, transparent four-corner resize targets, selection-first popup affordances and shape-local controls are existing design decisions. The code owns rejection messages at the assessment layer, but many gestures discard the result or only refresh. User-visible explanation of rejection is not a completed general interaction contract.

## 9 Audit findings against the design goals

### F01 Boundary Event type edits now persist through commit

**Fixed in the transaction follow-up; runtime verified.** Previously, CPBoundaryEvent>>eventDefinitionsDescription was read-only while CPAtelierSetBoundaryEventDefinition staged writes through it. GT correctly ignored the read-only field on commit. The description is now writable; GT commit rules are unchanged. boundaryEventDefinitionCommitAndReset proves root change detection, committed-model isolation before commit, reset to the original EventDefinition identity, persistence of Escalation on commit, and reset of a subsequent edit to that committed type. The ordinary Detail field now also sees writable metadata; this does not resolve F09's wider structural-editing policy gap.

### F02 Transfers preserve child mementos and committed topology

**Implemented in the transaction follow-up; eight focused lifecycle examples passed before the final ownership-order/status refinement. Final MCP verification did not complete; the final refinement remains unverified.** Single and group transfers now move the original child memento and its descendants instead of copying a hand-picked set of fields. The obsolete staged-field snapshots and restoration methods were removed from both operations and assessments. CPProcessFlowContainerContext>>transferChildMementoFor:to:inRootMemento: supplies the exact container description to CFMaMemento>>reparentChildMementoFor:from:inRelation:to:inRelation:ownerDescription:.

The common transaction root verifies that both parent mementos belong to its active tree, rejects a child cycle or occupied destination, moves lifecycle ownership, routes transferred-child status changes to the common root and journals the original ownership. Reset reverses that journal before resetting children, including a transferred child subsequently detached by removal. Commit publishes the current owner links of surviving transferred children before parent membership writes, then commits the active editing tree. Rollback journals are cleared before GT commit calls self reset; deleted child edits are not resurrected or committed. This is staged transaction behavior, not exception rollback or database atomicity.

Commit testing also exposed destructive collection replacement: CPProcess and CPSubProcess removed and re-added every flow element, clearing SequenceFlow endpoints even for retained topology. Their flowElements: setters now reconcile membership without removing retained elements. removeFlowElement: disconnects topology only when the element is still owned by that container, so a former source does not clear a transferred element's new ownership or connections.

The added regression examples exercise nested child identity and edits, Call Activity fields, staged/committed separation, root and sibling transfers, internal SequenceFlow endpoints and inverses, repeated transfer/reset, transfer followed by removal with commit/reset, and reversal of nested container ownership. Lane-reference cleanup remains F05. No claim is made that arbitrary direct relation edits or independent commits of child editors are equivalent to committing the owning root transaction.

### F03 Lane objects contradict their Magritte description contracts

**Runtime reproduced; metadata consistency.** CPAtelierCreateLane and related operations create CPShape modelElement: aLane, but CPShape>>modelElementDescription accepts only CPFlowNode and CPParticipant. CPLane is neither. Creation validates bounds and outer collections, not that inner modelElement description. Separately, CPLaneSet>>lanesDescription lacks beOrdered even though semantic insertion and native presentation use Lane order; base Magritte defaults to unordered. Direct validation of a CPLane against CPShape modelElementDescription raised MAMultipleErrors, and lanesDescription isOrdered returned false. Owner: Process model descriptions. Verify full memento validation/status as well as rendering; a visible Lane does not prove its metadata is valid.

### F04 Lane partition semantics exceed the renderer's supported domain

**Runtime reproduced for the second partition; source confirmed for parent-first lookup.** CPProcessVisualElement>>newTopLevelLaneSetVisualFromShapes: renders only stagedLaneSets first, but stagedLaneContainingFlowNode: traverses all top-level partitions and presentationHostForFlowNode: assumes the selected Lane has a rendered bodyHost. Rendering a disposable Process with a node assigned only in its second top-level LaneSet raised KeyNotFound because that Lane had no rendered bodyHost. Parent Lane membership is tested before child membership, so a node referenced at both levels resolves to the parent. The model allows independent partitions; the editor needs an explicit displayed-partition policy. Owner: Process Lane presentation and context selection.

### F05 Lane references are not maintained by all topology changes

**Runtime reproduced for removal and foreign assignment; source confirmed omission for transfer.** CPAtelierAssignFlowNodeToLane checks the target Lane hierarchy and value classes but does not establish that the node belongs to that Process's flow scope. RemoveFlowNode and single/group transfer do not coordinate Lane flowNodeRefs in their current implementations. A disposable node removal left the removed node in both staged and committed Lane flowNodeRefs. Assignment assessment accepted a fresh node that belonged to no Process. Scope-transfer Lane cleanup remains to be verified with a focused lifecycle probe. The normal cross-Lane gesture does stage geometry and assignment together, but it does not cover removal or transfer into a Sub-Process. Owner: Process operation dependency handling. Add scope, stale-reference, commit and reset cases when fixing.

### F06 A bare BPM model does not yet yield a useful editable diagram

**Source confirmed; product capability gap.** CPProcess>>initialize leaves diagram unset. CPProcess>>asAtelier does not create it. CPProcessVisualElement>>refresh returns when the staged diagram is nil and otherwise enumerates DI elements. Most create operations reject a missing diagram. A Process with flowElements but absent shapes is not automatically laid out or reconciled into depictions. Owner: Process presentation initialization and an explicit semantic-to-DI derivation policy. Preserve authored geometry when introducing defaults. Do not confuse this with the already implemented empty-Atelier root mechanism.

### F07 The documented Atelier details workspace is not implemented here

**Source confirmed, including live method spot check; design gap.** CPProcessPresentation>>prepareHostElement creates a fixed 380-wide scroll pane for Detail; no GtTreePager or BrResizer is constructed there. Selection rebuilds Detail for a sole semantic object and clears it otherwise. Foundation has a Phlow/Tree Pager navigation adapter, but that does not instantiate the promised workspace. Owner: Process workspace composition and any truly reusable Foundation hosting behavior. The prior document's resizable one-column Tree Pager statement must be read as design intent.

### F08 Diagram refresh rebuilds live visual identity

**Source confirmed; continuity and interaction risk.** CPProcessVisualElement>>refresh removes all children and clears shape, Lane and edge maps before rebuilding. Memento status observation refreshes the root unless a label is active. DI selection identity survives separately, but live element identity is not preserved by this path. The Process presentation/visual source does not establish the pervasive Motion integration asserted by Atelier v3. CFAtelierElement does use Motion for form replacement. Owner: Process refresh lifecycle; use Foundation Motion after authoritative layout, not as a second geometry model. Assess focus, camera, observer lifetime and performance before prescribing a refactor.

### F09 Shared mementos do not guarantee semantic equivalence of every editing surface

**Source confirmed; policy gap.** Process Detail is a plain CFMaViewModel/CFMaDetailPresentation over the selected child memento. Descriptions such as CPFlowElement>>containerDescription and CPSequenceFlow endpoint descriptions are editable, but this Detail construction does not install the BPM diagram operation adapter on each structural field. A direct relation edit can stage a change without the coordinated membership, inverse-relation and DI work of the corresponding diagram operation. Owner: Process field policy and Foundation's existing presentation configuration seams. Test the same intention through Detail and diagram; do not assume shared storage alone enforces equivalent domain behavior.

### F10 BPMN validation and interchange are explicitly partial

**Source confirmed; supported-domain boundary.** CPProcessValidator checks selected SequenceFlow endpoint, Start/End and duplicate-connection conditions. It does not recursively validate every nested Process, Lane/attachment invariant or diagram consistency, and it is not called by the current Process Atelier/presentation path as a comprehensive commit gate. Connection rules implement a subset; CPEvent's broad MessageFlow endpoint eligibility does not distinguish every catch/throw/event type constraint. SequenceFlow has only source/target beyond inherited metadata, without a complete expression/default-flow model. No BPMN XML importer/exporter or semantic-to-DI layout implementation was found in the audited Process source. The spec and bpmn-js are references, not evidence of conformance.

### F11 BPM runtime and loading documentation must distinguish two models

**Source confirmed; integration boundary.** CPProcessCompiler>>compileDesign: consumes the older CPProcessDesign nodes/edges and produces definitions for CPRuntimeEngine. No audited compiler path consumes the active CPProcess BPMN graph. Treat editor completion and executable BPM deployment as separate work. BaselineOfCatalystProcess declares Atelier and GT examples, but rowan/components/Process.ston omits BVC-BPM-Atelier and BVC-BPM-GT-Examples while including GT in a load specification described as GemStone. Neither fresh Pharo loading nor GemStone compatibility was verified by this audit. Do not promise the same editor from both load routes.

### F12 Assessments are richer than the feedback exposed to users

**Source confirmed in representative gestures; usability gap.** Concrete operations return rejectionMessage, but node drag release invokes operation apply and then refreshes without presenting the rejection reason. Other paths reduce assessments to booleans for target acceptance. This can restore authoritative state while leaving users unable to understand why an action failed. Owner: Process gesture feedback with reusable Atelier presentation only where appropriate. Verify feedback, cancellation and restoration together; do not add a parallel semantic rules engine in the UI.

## 10 What is implemented and what still needs verification

Source contains substantive operations and examples for staged create/move/resize/connect/reconnect/remove/replace, authored waypoints and edge labels, shared DI selection, closed-group transfer, Sub-Process expansion, Pool/MessageFlow composition, Boundary Event attachment and recursive Lane presentation. These are existing capabilities to extend, not blank areas to redesign.

Automatic layout, a complete BPMN data/expression model, general clipboard/copy-paste topology closure, full interchange, a CPProcess runtime compiler bridge, an integrated resizable Tree Pager and general stable visual refresh remain absent or incomplete in the audited paths. Foundation's generic Copy operation accepts an already materialized distinct object; that is not a Process graph clipboard implementation.

The user-experience checks still requiring a real editor session are: second Pool over blank Collaboration space; contextual Pool drops over Lane body/header; same-Lane and cross-Lane release coordinates; nested Sub-Process targeting at two levels; label focus and hit regions; Enter/Escape/Delete behavior; circular/diamond connector docking while dragging and reconnecting; Boundary Event dependencies under move/resize/remove; camera preservation; and commit/reset after combined edits. Existing example success must be reported separately from manual gesture verification.

## 11 Executable evidence and reproduction

Transaction follow-up verification: eight focused examples passed on the initial fix. The combined 289-example request timed out without a result and must not be counted as a pass. Final focused reruns, the nesting-reversal example, and a 30-example Foundation/model batch were requested after the ownership-order refinement; the nesting-reversal and Foundation/model requests timed out, and focused reruns had not returned when this reading copy was prepared. The final root-status subscription compilation also timed out; inspect the connected image before assuming it matches source. Verify those results before treating the final refinement as runtime proven. The source changes include new CPProcessAtelierExamples methods boundaryEventDefinitionCommitAndReset, groupTransferPreservesEditingTreeThroughCommit, singleTransferPreservesAllFieldsThroughCommit, groupTransferResetRestoresOriginalEditingTree, singleTransferRoundTripResetPreservesIdentity, transferThenRemoveResetRestoresDescendantIdentity, transferThenRemoveCommitDiscardsRemovedDescendantEdits, groupTransferBetweenSiblingContainersCommitsTopology and reversingNestedContainerOwnershipCommitsWithoutLosingLinks. The historical F01/F02 failure probes below document the pre-fix behavior; they are not the expected current result.

Original audit evidence follows.

The connected GT image ran **281 existing examples: 281 passed, zero failures, errors, skips or missing examples**. The two editor suites contributed 177; the additional Foundation and Process model batch contributed 104. These are runtime results, separate from the new probes below.

| Example class or group | Passed |
| --- | --- |
| CPProcessAtelierExamples | 64 |
| CPProcessVisualElementExamples | 113 |
| CPProcessExamples | 20 |
| CFMaEmbeddedTransactionExamples | 10 |
| CFMaPresentationExamples and CFMaPhlowNavigationExamples | 2 each |
| CFAtelierEntryExamples and CFAtelierEmptyEntryExamples | 6 and 3 |
| CFAtelierConfigurationExamples | 2 |
| CFAtelierMoveExamples and CFAtelierInsertExamples | 17 and 6 |
| CFAtelierReplaceExamples and CFAtelierRemoveExamples | 7 and 10 |
| CFAtelierReorderExamples and CFAtelierCopyExamples | 7 and 9 |
| CFAtelierReferenceExamples | 3 |

Focused disposable-object probes reproduced failures that those existing examples do not catch:

- **F01:** Use CPProcessAtelierExamples new boundaryEventFixture. Apply CPAtelierSetBoundaryEventDefinition with CPEscalationEventDefinition, inspect the Boundary Event child memento, then commit the root. Result: committed type before Timer; staged type Escalation; root hasChangesToCommit false; committed type after Timer.
- **F02:** Create a root with a Sub-Process containing a child Task, a destination Sub-Process and a companion Task, with DI shapes. Stage the child's label through its child memento. Transfer the containing Sub-Process and companion together with CPAtelierTransferFlowNodes. Resolve the child through the destination context. Result: assessment accepted; source staged label was the edit; destination staged label and committed label were the original value.
- **F03:** Evaluate CPShape new modelElementDescription validate: CPLane new with MAValidationError handling, and CPLaneSet new lanesDescription isOrdered. Result: MAMultipleErrors and false respectively. This checks metadata directly, not the entire editor status pipeline.
- **F04:** Start from CPProcessExamples new processWithTwoLanes, remove a chosen node from the first partition, add a second LaneSet containing it, and provide its node/Lane DI shapes. Build CPProcessVisualElement with a fresh CFMaMemento. Result: KeyNotFound.
- **F05:** With a fresh processWithTwoLanes and a DI shape for a Lane-assigned node, apply CPAtelierRemoveFlowNode and inspect Lane refs before and after root commit. Result: both still contain the removed node. Separately assess CPAtelierAssignFlowNodeToLane for a fresh uncontained Task and an existing Lane. Result: accepted.

These probes used disposable models and did not compile or alter loaded classes. They establish the recorded cases, not every variant or reset path. No fresh image load, SUnit suite, manual gesture session, exhaustive source/image comparison or full BPMN conformance test was performed. Live method spot checks covered presentation construction, Participant palette acceptance, Boundary Event metadata, GT commit filtering, shape metadata, transfer state handling and Lane rendering/assessment; they matched the checkout in those methods.

The checkout contains 64 gtExample methods in CPProcessAtelierExamples, 113 in CPProcessVisualElementExamples, and 20 in CPProcessExamples. Those source counts agree with the runtime suite totals above. CPProcessAtelierExamples is in BVC-BPM-Atelier, not BVC-BPM-GT-Examples. CPProcessExamples includes semantic and older runtime examples. SUnit tests CPRuntimeEngineTest, CPProcessCompilerTest and CPProcessDesignValidatorTest mostly exercise the older design/runtime path.

Relevant Foundation suites include CFMaEmbeddedTransactionExamples, CFMaPresentationExamples, CFMaPhlowNavigationExamples, CFMaDetailPresentationExamples and the CFAtelier*Examples classes for entry, empty root, configuration, move, insert, replace, remove, reorder, copy, reuse, palette/provider/capture and drop surfaces. Select suites by changed contract; do not call an example an SUnit test or assume Object-based examples support deny:.

To inspect the connected image, prefer GT class/method/source tools. exampleMethodRun takes an example reference with exampleClassName, methodName and classSide. examplesInClassesRun accepts an array of class names. Preserve returned totals and individual failures. Smalltalk evaluation is a last resort for a bounded disposable-object probe, not a means to compile code or silently modify loaded classes. A live source spot check is not complete checkout/image parity.

A useful existing starting model is CPProcessExamples new simpleProcess; inspect its source before using it because it deliberately creates DI. CPProcessAtelierExamples>>fixture returns a Process, root memento and related semantic/DI objects for operation examples. Use dedicated examples as examples, not as a public production API. Inspect an existing user's editor without committing or resetting their objects just to test a hypothesis.

## 12 How the next chat should work

F01 and F02 are addressed by the transaction follow-up. For follow-on work, prioritize invalid or stale Lane state and rendering failure (F03–F05), then consistent Detail/diagram structural editing (F09). The principal product gaps are bare-model diagram derivation (F06), workspace navigation/resizing (F07), visual continuity (F08) and rejection feedback (F12). Treat interchange and runtime integration (F10, F11) as explicit scope decisions. This ordering is an audit recommendation, not authorization to implement those changes.

Start with the current request, this guide's snapshot and git status. Read the relevant class/selector and its existing examples before editing. Decide whether the issue belongs to semantic rules, Magritte metadata, staged context ownership, an operation, presentation composition or the underlying framework. A rendered displacement is not automatically a DI error; a correct DI value is not proof of correct live parent coordinates.

Reproduce a concrete failure with disposable objects or a focused example. For state changes, inspect staged values, committed values before commit, values after commit and values after reset. Include prior staged edits, nested children, inverse collections and dependent relationships when those participate in the operation. For interaction changes, prove actual Bloc parentage, event target and focus ownership. Do not validate a gesture solely by calling its final operation.

Use explicit discoverable collaborators and existing configuration paths. Process classes use CP. Keep generic presentation choices in Foundation configuration, domain meaning in Process, and descriptions in Magritte. Use group/categories and description composition normally. Do not introduce respondsTo:-style compatibility probing or hidden selector dispatch to conceal an ownership problem. Existing legacy cfSerializable: use in Foundation is a source fact, not a reason to add new cf-prefixed APIs. Same-class rejection checks are not automatically forbidden class-switch architecture.

Do not modify deps or GT without explicit authorization. Do not reinterpret the old cleanup-complete statement as a ban on evidence-based corrections, or as proof that no defects remain. Conversely, a large class or superficial duplication alone is not a reason for another architectural extraction pass.

Record findings before fixes, then update this guide when a behavior materially changes. For each fixed finding, name the commit and the exact verification that changed its status. Replace obsolete status prose rather than accumulating contradictory addenda. Keep design goals, source facts and runtime evidence separate. Keep the Markdown and Word handover synchronized.

## 13 Source map

All paths below are relative to the workspace root. Locate a class as `<package>/<Class>.class.st`; extensions use `<Class>.extension.st`. Use selector names in the prose as durable locators; line numbers change.

| Area | Source directory and first classes to read |
| --- | --- |
| Foundation identity and descriptions | `CatalystFoundation/src/BVC-Foundation-Core` — CFObject, CFIdentifiableObject, CFLabelledObject |
| Foundation presentation configuration | `CatalystFoundation/src/BVC-Foundation-Magritte-Core` — MADescription and MAContainer extensions, CFMaFieldConfiguration and specialized configurations |
| Foundation editing and navigation | `CatalystFoundation/src/BVC-Foundation-Magritte-GT` — CFMaMemento, CFMaViewModel, CFMaPresentation, CFMaPhlowNavigation, CFEditableLabel |
| Foundation Detail | `CatalystFoundation/src/BVC-Foundation-Magritte-Detail` — CFMaDetailPresentation and field/group configuration extensions |
| Atelier | `CatalystFoundation/src/BVC-Foundation-Atelier` — Object extension, CFAtelierOperation, CFAtelierViewModel, CFAtelierElement, CFAtelierConfiguration, CFAtelierMove, CFAtelierEmptyViewModel |
| Motion | `CatalystFoundation/src/BVC-Motion-Core` — CFMotionLayoutTransaction and layout readiness/snapshot collaborators |
| BPMN semantics and DI | `CatalystProcess/src/BVC-BPM-BPMN` — CPProcess, CPSubProcess, CPLaneSet, CPLane, CPBoundaryEvent, CPSequenceFlow, CPDiagram, CPShape, CPEdge, connection rules and validator |
| BPM staged contexts | `CatalystProcess/src/BVC-BPM-Magritte` — CPProcessFlowContainerContext, CPDiagramMementoContext, CPProcessCollaborationContext, CPProcessLaneContext |
| BPM presentation | `CatalystProcess/src/BVC-BPM-GT` — CPProcessPresentation, CPProcessVisualElement, CPProcessShapeElement, CPProcessEdgeVisual, CPCollaborationVisualElement, CPLaneSetVisualElement, CPLaneShapeElement |
| BPM editing | `CatalystProcess/src/BVC-BPM-Atelier` — CPProcess extension, CPProcessAtelierConfiguration, CPProcessAtelierDiagramEditing, CPAtelier* operations and assessments |
| BPM visual examples | `CatalystProcess/src/BVC-BPM-GT-Examples` — CPProcessVisualElementExamples |
| Older compiler and runtime | `CatalystProcess/src/BVC-BPM-Design`, `BVC-BPM-Definition`, `BVC-BPM-Runtime`, `BVC-BPM-Automation` |
| Base Magritte | `deps/magritte/source/Magritte-Model` — MADescription, MAMemento, MAToManyRelationDescription |
| GT Magritte | `deps/gt4magritte/src/GToolkit4Magritte-Core` — GtMagritteMemento, GtMagritteBuilderUtility |
| Bloc | `deps/Bloc/src/Bloc` — BlElement; inspect layout/events packages as required |
| Brick and Phlow | `deps/Brick/src`, `deps/gtoolkit-phlow/src`, `deps/gtoolkit-inspector/src` |

For comparison in the supplied bpmn-js archive, start with lib/features/modeling/Modeling.js, BpmnUpdater.js, lib/features/rules/BpmnRules.js and lib/features/label-editing/LabelEditingProvider.js. BpmnUpdater separately updates semantic parents, DI parents, bounds and Lane references. Use these to ask sharper behavioral questions; do not copy its command architecture over the established Foundation memento boundary.
