local v_ver = [[Editor 1.96 Master]]
--[[ UI_functions version: 2.3 ( Reduced Locals for more less risk to due Out Of Local ) ]]

------------------------------------------------------------------------------------------

-- =====>> Saved Functions <<=====
-- ====FUNCTION CORNER===== Example: Corner(Scale, Offset, Parent)
local function Corner(Scale, Offset, Parent)
  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(Scale or 0, Offset or 0)
  Corner.Parent = Parent
  return Corner
end
-- =====END FUNCTION CORNER====

-- =====FUNCTION UILISTLAYOUT===== Example: ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
local ListUI = {
 HCenter = Enum.HorizontalAlignment.Center,
 VCenter = Enum.VerticalAlignment.Center,
 HLeft = Enum.HorizontalAlignment.Left,
 VTop = Enum.VerticalAlignment.Top,
 HRight = Enum.HorizontalAlignment.Right,
 VBottom = Enum.VerticalAlignment.Bottom,
 FillH = Enum.FillDirection.Horizontal,
 FillV = Enum.FillDirection.Vertical,
 SCustom = Enum.SortOrder.Custom,
 SLayout = Enum.SortOrder.LayoutOrder,
 SName = Enum.SortOrder.Name
}

local function ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(scale or 0, offset or 0)
    list.FillDirection = ListUI[FILL] or ListUI.FillH
    list.HorizontalAlignment = ListUI[HZ] or ListUI.HCenter
    list.VerticalAlignment = ListUI[VT] or ListUI.VCenter
    list.SortOrder = ListUI[SO] or ListUI.SName
    list.Parent = parent
    return list
end
-- =====END FUNCTION UILISTLAYOUT=====

-- ====FUNCTION UISTROKE===== Example: Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
local StrokeUI = {
 ASMBorder = Enum.ApplyStrokeMode.Border,
 ASMContextual = Enum.ApplyStrokeMode.Contextual,

 LJMBevel = Enum.LineJoinMode.Bevel,
 LJMMiter = Enum.LineJoinMode.Miter,
 LJMRound = Enum.LineJoinMode.Round
}

local function Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
    local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.ApplyStrokeMode = StrokeUI[ASM] or StrokeUI.ASMBorder
    stroke.Color = Color3.fromRGB(R or 255, G or 255, B or 255)
    stroke.LineJoinMode = StrokeUI[LJM] or StrokeUI.LJMRound
    stroke.Thickness = Tn or 1
    stroke.Transparency = Transy or 0
    stroke.Parent = parent
    return stroke
end
-- =====END FUNCTION UISTROKE=====

-- ====FUNCTION UIGRADIENT===== Example: Gradient(parent, rotation, offsetX, offsetY, {...}, {...})
local function Gradient(parent, rotation, offsetX, offsetY, colors, transparencies)
    local grad = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")

    grad.Rotation = rotation or 0
    grad.Offset = Vector2.new(offsetX or 0, offsetY or 0)

    -- Color
    local colorKeypoints = {}

    if not colors or #colors == 0 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
    elseif #colors == 1 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[1])
        }
    else
        for i, c in ipairs(colors) do
            local t = (i-1) / (#colors-1)
            table.insert(colorKeypoints, ColorSequenceKeypoint.new(t, c))
        end
    end

    grad.Color = ColorSequence.new(colorKeypoints)


    -- Transparency
    local transparencyKeypoints = {}

    if not transparencies or #transparencies == 0 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0)
        }
    elseif #transparencies == 1 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, transparencies[1]),
            NumberSequenceKeypoint.new(1, transparencies[1])
        }
    else
        for i, tValue in ipairs(transparencies) do
            local t = (i-1) / (#transparencies-1)
            table.insert(
                transparencyKeypoints,
                NumberSequenceKeypoint.new(t, tValue)
            )
        end
    end

    grad.Transparency = NumberSequence.new(transparencyKeypoints)

    grad.Parent = parent
    return grad
end
-- =====END FUNCTION UIGRADIENT=====

-- ====FUNCTION UIPADDING ===== Example: Padding(parent, {X, Y}, {X, Y}, {X, Y}, {X, Y})
local function Padding(parent, bottom, left, right, top)
    local pad = parent:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
    local function toUDim(value)
        if typeof(value) == "UDim" then
            return value
        elseif type(value) == "number" then
            return UDim.new(0, value)
        elseif type(value) == "table" and #value >= 2 then
            return UDim.new(value[1] or 0, value[2] or 0)
        else
            return UDim.new(0, 0)
        end
    end

    pad.PaddingBottom = toUDim(bottom)
    pad.PaddingLeft   = toUDim(left)
    pad.PaddingRight  = toUDim(right)
    pad.PaddingTop    = toUDim(top)

    pad.Parent = parent
    return pad
end

-- =====FUNCTION UIASPECTRATIONCONSTRAINT==== Example: Aspect(parent, ratio, aspectType, dominantAxis)

--// ENUM SHORTCUTS
local Axis = Enum.DominantAxis
local Type = Enum.AspectType

local AspectUI = {
 Axis = Enum.DominantAxis,
 Type = Enum.AspectType,

-- optional ultra-short aliases
 Width = Axis.Width,
 Height = Axis.Height,

 Fit = Type.FitWithinMaxSize,
 Scale = Type.ScaleWithParentSize
}


--// ASPECT FUNCTION
function Aspect(parent, ratio, aspectType, dominantAxis)
	if not parent then return end
	
	-- prevent duplicates
	local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
	if existing then
		-- update instead
		existing.AspectRatio = AspectUI[ratio] or existing.AspectRatio
		existing.AspectType = AspectUI[aspectType] or existing.AspectType
		existing.DominantAxis = AspectUI[dominantAxis] or existing.DominantAxis
		return existing
	end
	
	-- create new
	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.Parent = parent
	
	constraint.AspectRatio = AspectUI[ratio] or 1
	constraint.AspectType = AspectUI[aspectType] or AspectUI.Fit
	constraint.DominantAxis = AspectUI[dominantAxis] or AspectUI.Width
	
	return constraint
end

-- =====END FUNCTION UIASPECTRATIONCONSTRAINT=====

--[[
====== CLIENT SERVICES ( OLD ) ======

-- UI / Player Interface
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 3D/2D Destroy
local Debris = game:GetService("Debris")

-- 3D Wprkspace
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- Storage
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
]]

--====== CLIENT SERVICES ( TABLE ); Use like this 'Service.Example' ======--

local s = {
-- UI / Player Interface
 CoreGui = game:GetService("CoreGui"),
 StarterGui = game:GetService("StarterGui"),
 GuiService = game:GetService("GuiService"),
 Players = game:GetService("Players"),
 LogService = game:GetService("LogService"),

-- 3D/2D Destroy
 Debris = game:GetService("Debris"),

-- 3D Wprkspace
 Workspace = game:GetService("Workspace"),
 TeleportService = game:GetService("TeleportService"),
 Lighting = game:GetService("Lighting"),
 Camera = Workspace.CurrentCamera,

-- Storage
 ReplicatedStorage = game:GetService("ReplicatedStorage"),

-- Third Party
 HttpService = game:GetService("HttpService"),

-- Audio / Feedback
 SoundService = game:GetService("SoundService"),

-- Commerce / Monetization
 MarketplaceService = game:GetService("MarketplaceService"),

-- Runtime / Frame Updates
 RunService = game:GetService("RunService"),
 TextService = game:GetService("TextService"),
 TextChatService = game:GetService("TextChatService"),

-- Animation / Transitions
 TweenService = game:GetService("TweenService"),
 ContentProvider = game:GetService("ContentProvider"),

-- Input (Desktop / Mobile)
 UserInputService = game:GetService("UserInputService"),
 TouchInputService = game:GetService("TouchInputService"),

}

-- All local in one tabel; Use like this 'loc.Example'
local loc = {
  -- v Local V
  
}

-- Roblox API Reference
Classes = {
  "Accessory",
  "AccessoryDescription",
  "AccountService",
  "Accoutrement",
  "AchievementService",
  "ActivityHistoryEventService",
  "Actor",
  "AdGui",
  "AdPlacement",
  "AdPortal",
  "AdService",
  "AdvancedDragger",
  "AirController",
  "AlignOrientation",
  "AlignPosition",
  "AnalyticsService",
  "AngularVelocity",
  "AnimatedImage",
  "AnimatedImageService",
  "AnimatedImageTrack",
  "Animation",
  "AnimationClip",
  "AnimationClipProvider",
  "AnimationConstraint",
  "AnimationController",
  "AnimationFromVideoCreatorService",
  "AnimationFromVideoCreatorStudioService",
  "AnimationGraphDefinition",
  "AnimationImportData",
  "AnimationNode",
  "AnimationNodeDefinition",
  "AnimationRigData",
  "AnimationStreamTrack",
  "AnimationTrack",
  "AnimationValueNodeDefinition",
  "AnimationValueOutputDefinition",
  "Animator",
  "Annotation",
  "AnnotationsService",
  "AppAgeSignalsService",
  "AppLifecycleObserverService",
  "AppRatingPromptService",
  "AppStorageService",
  "AppUpdateService",
  "ArcHandles",
  "AssetCounterService",
  "AssetDeliveryProxy",
  "AssetImportService",
  "AssetImportSession",
  "AssetManagerService",
  "AssetPatchSettings",
  "AssetQualityService",
  "AssetService",
  "AssetSoundEffect",
  "Atmosphere",
  "AtmosphereSensor",
  "Attachment",
  "AudioAnalyzer",
  "AudioChannelMixer",
  "AudioChannelSplitter",
  "AudioChorus",
  "AudioCompressor",
  "AudioDeviceInput",
  "AudioDeviceOutput",
  "AudioDistortion",
  "AudioEcho",
  "AudioEmitter",
  "AudioEqualizer",
  "AudioFader",
  "AudioFilter",
  "AudioFlanger",
  "AudioFocusService",
  "AudioGate",
  "AudioLimiter",
  "AudioListener",
  "AudioPages",
  "AudioPitchShifter",
  "AudioPlayer",
  "AudioRecorder",
  "AudioReverb",
  "AudioSearchParams",
  "AudioSpeechToText",
  "AudioTextToSpeech",
  "AudioTremolo",
  "AudioWindSynthesizer",
  "AuroraScript",
  "AuroraScriptObject",
  "AuroraScriptService",
  "AuroraService",
  "AvatarAbilityRules",
  "AvatarAccessoryRules",
  "AvatarAnimationRules",
  "AvatarBodyRules",
  "AvatarChatService",
  "AvatarClothingRules",
  "AvatarCollisionRules",
  "AvatarCreationService",
  "AvatarEditorService",
  "AvatarImportService",
  "AvatarRules",
  "AvatarSettings",
  "BackendReplicatedStorage",
  "BackendServerScriptService",
  "BackendServerStorage",
  "Backpack",
  "BackpackItem",
  "BadgeService",
  "BallSocketConstraint",
  "BanHistoryPages",
  "BaseCoreGuiConfiguration",
  "BaseImportData",
  "BasePart",
  "BasePlayerGui",
  "BaseRemoteEvent",
  "BaseScript",
  "BaseWrap",
  "Beam",
  "BevelMesh",
  "BillboardGui",
  "BinaryStringValue",
  "BindableEvent",
  "BindableFunction",
  "BlockMesh",
  "BloomEffect",
  "BlurEffect",
  "BodyAngularVelocity",
  "BodyColors",
  "BodyForce",
  "BodyGyro",
  "BodyMover",
  "BodyPartDescription",
  "BodyPosition",
  "BodyThrust",
  "BodyVelocity",
  "Bone",
  "BoolValue",
  "BoxHandleAdornment",
  "BranchService",
  "Breakpoint",
  "BrickColorValue",
  "BrowserService",
  "BubbleChatConfiguration",
  "BubbleChatMessageProperties",
  "BugReporterService",
  "BulkImportService",
  "BuoyancySensor",
  "CacheableContentProvider",
  "CallingService",
  "CalloutService",
  "Camera",
  "CanvasGroup",
  "Capture",
  "CaptureService",
  "CapturesPages",
  "CapturesViewConfiguration",
  "CatalogPages",
  "CFrameValue",
  "ChangeHistoryService",
  "ChangeHistoryStreamingService",
  "ChannelSelectorSoundEffect",
  "ChannelTabsConfiguration",
  "CharacterAppearance",
  "CharacterMesh",
  "Chat",
  "ChatInputBarConfiguration",
  "ChatWindowConfiguration",
  "ChatWindowMessageProperties",
  "ChorusSoundEffect",
  "ClickDetector",
  "ClientReplicator",
  "ClientStorageService",
  "ClimbController",
  "Clothing",
  "CloudCRUDService",
  "CloudExecutionService",
  "CloudLocalizationTable",
  "Clouds",
  "ClusterPacketCache",
  "Collaborator",
  "CollaboratorsService",
  "CollectionService",
  "Color3Value",
  "ColorCorrectionEffect",
  "ColorGradingEffect",
  "CommerceService",
  "CompositeValueCurve",
  "CompressorSoundEffect",
  "ConeHandleAdornment",
  "ConfigService",
  "ConfigSnapshot",
  "Configuration",
  "ConfigureServerService",
  "ConnectivityService",
  "Constraint",
  "ContentProvider",
  "ContextActionService",
  "Controller",
  "ControllerBase",
  "ControllerManager",
  "ControllerPartSensor",
  "ControllerSensor",
  "ControllerService",
  "ControlState",
  "CookiesService",
  "CoreGui",
  "CoreGuiConfiguration",
  "CorePackages",
  "CoreScript",
  "CoreScriptDebuggingManagerHelper",
  "CoreScriptSyncService",
  "CornerWedgePart",
  "CreationDBService",
  "CreatorStoreService",
  "CrossDMScriptChangeListener",
  "CSGDictionaryService",
  "CurveAnimation",
  "CustomEvent",
  "CustomEventReceiver",
  "CustomLog",
  "CustomSoundEffect",
  "CylinderHandleAdornment",
  "CylinderMesh",
  "CylindricalConstraint",
  "DataModel",
  "DataModelDiff",
  "DataModelMesh",
  "DataModelSession",
  "DataStore",
  "DataStoreGetOptions",
  "DataStoreIncrementOptions",
  "DataStoreInfo",
  "DataStoreKey",
  "DataStoreKeyInfo",
  "DataStoreKeyPages",
  "DataStoreListingPages",
  "DataStoreObjectVersionInfo",
  "DataStoreOptions",
  "DataStorePages",
  "DataStoreService",
  "DataStoreSetOptions",
  "DataStoreVersionPages",
  "Debris",
  "DebuggablePluginWatcher",
  "DebuggerBreakpoint",
  "DebuggerConnection",
  "DebuggerConnectionManager",
  "DebuggerLuaResponse",
  "DebuggerManager",
  "DebuggerUIService",
  "DebuggerVariable",
  "DebuggerWatch",
  "DebugSettings",
  "Decal",
  "DeferredAssetManagerService",
  "DepthOfFieldEffect",
  "DesignFoundationsService",
  "DeviceDisplayService",
  "DeviceIdService",
  "Dialog",
  "DialogChoice",
  "DigitsRigDescription",
  "DisplayWakeLock",
  "DistortionSoundEffect",
  "DockWidgetPluginGui",
  "DoubleConstrainedValue",
  "DraftsService",
  "DragDetector",
  "Dragger",
  "DraggerService",
  "DynamicRotate",
  "EchoSoundEffect",
  "EditableImage",
  "EditableMesh",
  "EditableService",
  "EditorSourceService",
  "EncodingService",
  "EqualizerSoundEffect",
  "EulerRotationCurve",
  "EventIngestService",
  "ExampleV2Service",
  "ExecutedRemoteCommand",
  "ExperienceAuthService",
  "ExperienceInviteOptions",
  "ExperienceNotificationService",
  "ExperienceService",
  "ExperienceStateCaptureService",
  "ExperienceStateRecordingService",
  "ExplorerFilter",
  "ExplorerFilterAutocompleter",
  "ExplorerServiceVisibilityService",
  "Explosion",
  "ExternalIdentityService",
  "FaceAnimatorService",
  "FaceControls",
  "FaceInstance",
  "FacialAgeEstimationService",
  "FacialAnimationRecordingService",
  "FacialAnimationStreamingServiceStats",
  "FacialAnimationStreamingServiceV2",
  "FacialAnimationStreamingSubsessionStats",
  "FacsImportData",
  "Feature",
  "FeatureRestrictionManager",
  "File",
  "FileManagerService",
  "FileMesh",
  "FileSyncReplicationService",
  "Fire",
  "Flag",
  "FlagStand",
  "FlagStandService",
  "FlangeSoundEffect",
  "FloatCurve",
  "FloorWire",
  "FluidForceSensor",
  "FlyweightService",
  "Folder",
  "ForceField",
  "FormFactorPart",
  "Frame",
  "FriendPages",
  "FriendsCallingInstance",
  "FriendsCallingParticipant",
  "FriendService",
  "FunctionalTest",
  "GamepadService",
  "GamePassService",
  "GameSettings",
  "GeneratedFolder",
  "GenerationService",
  "GenericChallengeService",
  "GenericSettings",
  "Geometry",
  "GeometryService",
  "GetTextBoundsParams",
  "GlobalDataStore",
  "GlobalSettings",
  "Glue",
  "GongService",
  "GroundController",
  "GroupImportData",
  "GroupService",
  "GuiBase",
  "GuiBase2d",
  "GuiBase3d",
  "GuiButton",
  "GuidRegistryService",
  "GuiLabel",
  "GuiMain",
  "GuiObject",
  "GuiService",
  "HandleAdornment",
  "Handles",
  "HandlesBase",
  "HapticEffect",
  "HapticService",
  "HarmonyService",
  "Hat",
  "HeapProfilerService",
  "HeatmapQueryService",
  "HeatmapService",
  "HeightmapImporterService",
  "HiddenSurfaceRemovalAsset",
  "Highlight",
  "HingeConstraint",
  "Hint",
  "Hole",
  "Hopper",
  "HopperBin",
  "HSRDataContentProvider",
  "HttpRbxApiService",
  "HttpRequest",
  "HttpService",
  "Humanoid",
  "HumanoidController",
  "HumanoidDescription",
  "HumanoidRigDescription",
  "IKControl",
  "ILegacyStudioBridge",
  "ImageButton",
  "ImageHandleAdornment",
  "ImageLabel",
  "ImageScreenCaptureService",
  "ImportSession",
  "IncrementalPatchBuilder",
  "InputAction",
  "InputActionLabel",
  "InputBinding",
  "InputContext",
  "InputObject",
  "InsertService",
  "Instance",
  "InstanceAdornment",
  "InstanceExtensionsService",
  "InstanceFileSyncService",
  "IntConstrainedValue",
  "IntentService",
  "InternalMessagingService",
  "InternalMessagingServiceVerifier",
  "InternalSyncItem",
  "InternalSyncService",
  "IntersectOperation",
  "IntValue",
  "InventoryPages",
  "IXPService",
  "JointImportData",
  "JointInstance",
  "JointsService",
  "KeyboardService",
  "Keyframe",
  "KeyframeMarker",
  "KeyframeSequence",
  "KeyframeSequenceProvider",
  "LanguageService",
  "LayerCollector",
  "LegacyStudioBridge",
  "Light",
  "Lighting",
  "LinearVelocity",
  "LineForce",
  "LineHandleAdornment",
  "LinkingService",
  "LiveScriptingService",
  "LiveSyncService",
  "LocalDebuggerConnection",
  "LocalizationService",
  "LocalizationTable",
  "LocalScript",
  "LocalStorageService",
  "LodDataEntity",
  "LodDataService",
  "Logger",
  "LoginService",
  "LogReporterService",
  "LogService",
  "LuaSettings",
  "LuaSourceContainer",
  "LuauExpression",
  "LuauExpressionService",
  "LuauScriptAnalyzerService",
  "LuaWebService",
  "MakeupDescription",
  "ManualGlue",
  "ManualSurfaceJointInstance",
  "ManualWeld",
  "MarkerCurve",
  "MarketplaceService",
  "MatchmakingService",
  "MaterialGenerationService",
  "MaterialImportData",
  "MaterialService",
  "MaterialVariant",
  "MemoryStoreDistributedCounter",
  "MemoryStoreHashMap",
  "MemoryStoreHashMapPages",
  "MemoryStoreQueue",
  "MemoryStoreService",
  "MemoryStoreSortedMap",
  "MemStorageConnection",
  "MemStorageService",
  "MeshContentProvider",
  "MeshImportData",
  "MeshPart",
  "Message",
  "MessageBusConnection",
  "MessageBusService",
  "MessagingService",
  "MetaBreakpoint",
  "MetaBreakpointContext",
  "MetaBreakpointManager",
  "MicroProfilerService",
  "MLModelDeliveryService",
  "MLService",
  "MLSession",
  "Model",
  "ModerationService",
  "ModuleScript",
  "MomentsService",
  "Motor",
  "Motor6D",
  "MotorFeature",
  "Mouse",
  "MouseService",
  "MultipleDocumentInterfaceInstance",
  "NegateOperation",
  "NetworkClient",
  "NetworkMarker",
  "NetworkPeer",
  "NetworkReplicator",
  "NetworkServer",
  "NetworkSettings",
  "NoCollisionConstraint",
  "Noise",
  "NonReplicatedCSGDictionaryService",
  "NotificationService",
  "NumberPose",
  "NumberValue",
  "Object",
  "ObjectValue",
  "OmniRecommendationsService",
  "OpenCloudApiV1",
  "OpenCloudService",
  "OperationGraph",
  "OrderedDataStore",
  "OutfitPages",
  "OutputLink",
  "PackageLink",
  "Packages",
  "PackageService",
  "PackageUIService",
  "Pages",
  "Pants",
  "ParabolaAdornment",
  "Part",
  "PartAdornment",
  "ParticleEmitter",
  "PartOperation",
  "PartOperationAsset",
  "PartyEmulatorService",
  "PatchBundlerFileWatch",
  "PatchMapping",
  "Path",
  "Path2D",
  "Path3D",
  "PathfindingLink",
  "PathfindingModifier",
  "PathfindingService",
  "PausedState",
  "PausedStateBreakpoint",
  "PausedStateException",
  "PerformanceControlService",
  "PermissionsService",
  "PhysicsService",
  "PhysicsSettings",
  "PinShortcutService",
  "PitchShiftSoundEffect",
  "PlaceAssetIdsService",
  "PlacesService",
  "PlaceStatsService",
  "Plane",
  "PlaneConstraint",
  "Platform",
  "PlatformCloudStorageService",
  "PlatformFriendsService",
  "PlatformLibraries",
  "Player",
  "PlayerData",
  "PlayerDataRecord",
  "PlayerDataRecordConfig",
  "PlayerDataService",
  "PlayerEmulatorService",
  "PlayerGui",
  "PlayerHydrationService",
  "PlayerListConfiguration",
  "PlayerMouse",
  "Players",
  "PlayerScripts",
  "PlayerViewService",
  "Plugin",
  "PluginAction",
  "PluginCapabilities",
  "PluginConnection",
  "PluginConnectionService",
  "PluginDebugService",
  "PluginDragEvent",
  "PluginGui",
  "PluginGuiService",
  "PluginManagementService",
  "PluginManager",
  "PluginManagerInterface",
  "PluginMenu",
  "PluginMouse",
  "PluginPolicyService",
  "PluginToolbar",
  "PluginToolbarButton",
  "PointLight",
  "PointsService",
  "PolicyService",
  "PopLatencyService",
  "Pose",
  "PoseBase",
  "PostEffect",
  "Preloaded",
  "PrismaticConstraint",
  "ProceduralBehaviorSchedulerService",
  "ProceduralModel",
  "ProcessInstancePhysicsService",
  "ProjectService",
  "ProximityPrompt",
  "ProximityPromptService",
  "PublishService",
  "PVAdornment",
  "PVInstance",
  "PyramidHandleAdornment",
  "QueueService",
  "QWidgetPluginGui",
  "RayValue",
  "RbxAnalyticsService",
  "RealtimeMedia",
  "RecommendationPages",
  "RecommendationService",
  "ReflectionMetadata",
  "ReflectionMetadataCallbacks",
  "ReflectionMetadataClass",
  "ReflectionMetadataClasses",
  "ReflectionMetadataEnum",
  "ReflectionMetadataEnumItem",
  "ReflectionMetadataEnums",
  "ReflectionMetadataEvents",
  "ReflectionMetadataFunctions",
  "ReflectionMetadataItem",
  "ReflectionMetadataMember",
  "ReflectionMetadataProperties",
  "ReflectionMetadataYieldFunctions",
  "ReflectionService",
  "RelativeGui",
  "RemoteCommandService",
  "RemoteCursorService",
  "RemoteDebuggerServer",
  "RemoteEvent",
  "RemoteFunction",
  "RenderingTest",
  "RenderSettings",
  "ReplicatedFirst",
  "ReplicatedStorage",
  "RequestOrchestratorService",
  "ReverbSoundEffect",
  "RibbonNotificationService",
  "RigidConstraint",
  "RobloxPluginGuiService",
  "RobloxReplicatedStorage",
  "RobloxSerializableInstance",
  "RobloxServerStorage",
  "RocketPropulsion",
  "RodConstraint",
  "RolloutValidation",
  "RolloutValidationService",
  "RomarkRbxAnalyticsService",
  "RomarkService",
  "RootImportData",
  "RopeConstraint",
  "Rotate",
  "RotateP",
  "RotateV",
  "RotationCurve",
  "RTAnimationTracker",
  "RtMessagingService",
  "RunningAverageItemDouble",
  "RunningAverageItemInt",
  "RunningAverageTimeIntervalItem",
  "RunService",
  "RuntimeContentService",
  "RuntimeScriptService",
  "SafetyService",
  "SceneAnalysisService",
  "ScreenGui",
  "ScreenshotCapture",
  "ScreenshotHud",
  "Script",
  "ScriptBuilder",
  "ScriptChangeService",
  "ScriptCloneWatcher",
  "ScriptCloneWatcherHelper",
  "ScriptCommitService",
  "ScriptContext",
  "ScriptDebugger",
  "ScriptDebuggerService",
  "ScriptDocument",
  "ScriptEditorService",
  "ScriptProfilerService",
  "ScriptRegistrationService",
  "ScriptRuntime",
  "ScriptScannerService",
  "ScriptService",
  "ScrollingFrame",
  "Seat",
  "Selection",
  "SelectionBox",
  "SelectionHighlightManager",
  "SelectionLasso",
  "SelectionPartLasso",
  "SelectionPointLasso",
  "SelectionSphere",
  "SelfViewConfiguration",
  "SensorBase",
  "SerializationService",
  "ServerReplicator",
  "ServerScriptService",
  "ServerStorage",
  "ServiceProvider",
  "ServiceVisibilityService",
  "SessionCheckService",
  "SessionService",
  "SharedTableRegistry",
  "Shirt",
  "ShirtGraphic",
  "SkateboardController",
  "SkateboardPlatform",
  "Skin",
  "Sky",
  "SlidingBallConstraint",
  "SlimAnimationDataEntity",
  "SlimAnimationReplicationService",
  "SlimContentProvider",
  "SlimDebugSettings",
  "SlimReplicationService",
  "SlimService",
  "Smoke",
  "SmoothVoxelsUpgraderService",
  "Snap",
  "SocialService",
  "SolidModelContentProvider",
  "Sound",
  "SoundEffect",
  "SoundGroup",
  "SoundService",
  "SoundShimService",
  "Sparkles",
  "SpawnerService",
  "SpawnLocation",
  "SpecialMesh",
  "SphereHandleAdornment",
  "SpotLight",
  "SpringConstraint",
  "StackFrame",
  "StandalonePluginScripts",
  "StandardPages",
  "StandardQueue",
  "StarterCharacterScripts",
  "StarterGear",
  "StarterGui",
  "StarterPack",
  "StarterPlayer",
  "StarterPlayerScripts",
  "StartPageService",
  "StartupMessageService",
  "StateMachineDefinition",
  "StateMachineTransitionDefinition",
  "Stats",
  "StatsItem",
  "Status",
  "StopWatchReporter",
  "StringValue",
  "Studio",
  "StudioActionOverride",
  "StudioAssetService",
  "StudioAttachment",
  "StudioCallout",
  "StudioCameraService",
  "StudioCaptureService",
  "StudioData",
  "StudioDeviceEmulatorService",
  "StudioDeviceSimulatorService",
  "StudioObjectBase",
  "StudioPublishService",
  "StudioScreenshotCapture",
  "StudioScriptDebugEventListener",
  "StudioSdkService",
  "StudioService",
  "StudioTestService",
  "StudioTheme",
  "StudioUserService",
  "StudioWidget",
  "StudioWidgetsService",
  "StyleBase",
  "StyleDerive",
  "StyleLink",
  "StyleQuery",
  "StyleRule",
  "StyleSheet",
  "StylingService",
  "SunRaysEffect",
  "SurfaceAppearance",
  "SurfaceGui",
  "SurfaceGuiBase",
  "SurfaceLight",
  "SurfaceSelection",
  "SwimController",
  "SyncScriptBuilder",
  "SystemThemeService",
  "TaskScheduler",
  "Team",
  "TeamCreateData",
  "TeamCreatePublishService",
  "TeamCreateService",
  "Teams",
  "TelemetryService",
  "TeleportAsyncResult",
  "TeleportOptions",
  "TeleportService",
  "TemporaryCageMeshProvider",
  "TemporaryScriptService",
  "Terrain",
  "TerrainDetail",
  "TerrainIterateOperation",
  "TerrainModifyOperation",
  "TerrainReadOperation",
  "TerrainRegion",
  "TerrainWriteOperation",
  "TestCase",
  "TestService",
  "TextBox",
  "TextBoxService",
  "TextButton",
  "TextChannel",
  "TextChannelWindow",
  "TextChatCommand",
  "TextChatConfigurations",
  "TextChatMessage",
  "TextChatMessageProperties",
  "TextChatService",
  "TextDocument",
  "TextFilterResult",
  "TextFilterTranslatedResult",
  "TextGenerator",
  "TextLabel",
  "TextService",
  "TextSource",
  "Texture",
  "TextureGenerationPartGroup",
  "TextureGenerationService",
  "TextureGenerationUnwrappingRequest",
  "ThirdPartyUserService",
  "ThreadState",
  "TimerService",
  "ToastNotificationService",
  "Tool",
  "Torque",
  "TorsionSpringConstraint",
  "TotalCountTimeIntervalItem",
  "TouchInputService",
  "TouchTransmitter",
  "TraceRouteService",
  "TracerService",
  "TrackerLodController",
  "TrackerStreamAnimation",
  "Trail",
  "Translator",
  "TremoloSoundEffect",
  "TriangleMeshPart",
  "TrussPart",
  "TutorialService",
  "Tween",
  "TweenBase",
  "TweenService",
  "UGCAvatarService",
  "UGCValidationService",
  "UIAspectRatioConstraint",
  "UIBase",
  "UIComponent",
  "UIConstraint",
  "UICorner",
  "UIDragDetector",
  "UIDragDetectorService",
  "UIFlexItem",
  "UIGradient",
  "UIGridLayout",
  "UIGridStyleLayout",
  "UILayout",
  "UIListLayout",
  "UIPadding",
  "UIPageLayout",
  "UIScale",
  "UIShadow",
  "UISizeConstraint",
  "UIStroke",
  "UITableLayout",
  "UITextSizeConstraint",
  "UnionOperation",
  "UniqueIdLookupService",
  "UniversalConstraint",
  "UnreliableRemoteEvent",
  "UnvalidatedAssetService",
  "UserGameSettings",
  "UserInputService",
  "UserService",
  "UserSettings",
  "UserStorageService",
  "ValueBase",
  "ValueCurve",
  "Vector3Curve",
  "Vector3Value",
  "VectorForce",
  "VehicleController",
  "VehicleSeat",
  "VelocityMotor",
  "VersionControlService",
  "VideoCapture",
  "VideoCaptureService",
  "VideoDeviceInput",
  "VideoDisplay",
  "VideoFrame",
  "VideoPlayer",
  "VideoSampler",
  "VideoScreenCaptureService",
  "VideoService",
  "ViewportCamera",
  "ViewportFrame",
  "VirtualInput",
  "VirtualInputManager",
  "VirtualUser",
  "VisibilityCheckDispatcher",
  "Visit",
  "VisualizationMode",
  "VisualizationModeCategory",
  "VisualizationModeService",
  "VoiceChatInternal",
  "VoiceChatService",
  "VoxelBuffer",
  "VRService",
  "VRStatusService",
  "WebSocketClient",
  "WebSocketService",
  "WebStreamClient",
  "WebViewService",
  "WedgePart",
  "Weld",
  "WeldConstraint",
  "WindowProtocolService",
  "Wire",
  "WireframeHandleAdornment",
  "Workspace",
  "WorkspaceAnnotation",
  "WorldModel",
  "WorldRoot",
  "WrapContentProvider",
  "WrapDeformer",
  "WrapDeformMeshProvider",
  "WrapLayer",
  "WrapTarget",
  "WrapTextureTransfer",
}

Enums = {
  "AccessModifierType",
  "AccessoryType",
  "ActionOnAutoResumeSync",
  "ActionOnStopSync",
  "ActionType",
  "ActivePayerStatus",
  "ActuatorRelativeTo",
  "ActuatorType",
  "AdAvailabilityResult",
  "AdEventType",
  "AdFormat",
  "AdShape",
  "AdTeleportMethod",
  "AdUIEventType",
  "AdUIType",
  "AdUnitStatus",
  "AdornCullingMode",
  "AdornShading",
  "AgeCheckStatus",
  "AlignType",
  "AlphaMode",
  "AnalyticsCustomFieldKeys",
  "AnalyticsEconomyAction",
  "AnalyticsEconomyFlowType",
  "AnalyticsEconomyTransactionType",
  "AnalyticsLogLevel",
  "AnalyticsProgressionStatus",
  "AnalyticsProgressionType",
  "AnimatedImagePlaybackState",
  "AnimatedImageScaleType",
  "AnimationClipFromVideoStatus",
  "AnimationNodeBlend2DInputMode",
  "AnimationNodeBlendMode",
  "AnimationNodeInterruptible",
  "AnimationNodePhaseSync",
  "AnimationNodePlayMode",
  "AnimationNodeTransitionType",
  "AnimationNodeTransitionWhen",
  "AnimationNodeType",
  "AnimationNodeWaitFor",
  "AnimationPriority",
  "AnimationValueNodeType",
  "AnimatorRetargetingMode",
  "AnnotationChannelContentPreference",
  "AnnotationEditingMode",
  "AnnotationPlaceContentPreference",
  "AnnotationRequestStatus",
  "AnnotationRequestType",
  "AntiAliasing",
  "AppLifecycleManagerState",
  "AppShellActionType",
  "AppShellFeature",
  "AppUpdateStatus",
  "ApplyShadowMode",
  "ApplyStrokeMode",
  "AspectType",
  "AssetCreatorType",
  "AssetFetchStatus",
  "AssetRepresentation",
  "AssetType",
  "AssetTypeVerification",
  "AudioApiRollout",
  "AudioCaptureMode",
  "AudioChannelLayout",
  "AudioFilterType",
  "AudioPositionType",
  "AudioSampleFormat",
  "AudioSimulationFidelity",
  "AudioSubType",
  "AudioWindowSize",
  "AuthorityMode",
  "AutoIndentRule",
  "AutomaticSize",
  "AvatarAssetType",
  "AvatarChatServiceFeature",
  "AvatarContextMenuOption",
  "AvatarGenerationError",
  "AvatarItemType",
  "AvatarPromptResult",
  "AvatarSettingsAccessoryLimitMethod",
  "AvatarSettingsAccessoryMode",
  "AvatarSettingsAnimationClipsMode",
  "AvatarSettingsAnimationPacksMode",
  "AvatarSettingsAppearanceMode",
  "AvatarSettingsBuildMode",
  "AvatarSettingsCharacterControllerMode",
  "AvatarSettingsClothingMode",
  "AvatarSettingsCollisionMode",
  "AvatarSettingsCustomAccessoryMode",
  "AvatarSettingsCustomBodyType",
  "AvatarSettingsCustomClothingMode",
  "AvatarSettingsHitAndTouchDetectionMode",
  "AvatarSettingsJumpMode",
  "AvatarSettingsLegacyCollisionMode",
  "AvatarSettingsScaleMode",
  "AvatarThumbnailCustomizationType",
  "AvatarUnificationMode",
  "Axis",
  "BasicMeshPartShape",
  "BenefitType",
  "BinType",
  "BodyPart",
  "BodyPartR15",
  "BorderMode",
  "BorderStrokePosition",
  "BranchStatus",
  "BreakReason",
  "BreakpointRemoveReason",
  "BulkMoveMode",
  "BundleType",
  "Button",
  "ButtonStyle",
  "CageType",
  "CameraMode",
  "CameraNavigationModel",
  "CameraPanMode",
  "CameraSpeedAdjustBinding",
  "CameraType",
  "CanCollaborateError",
  "CaptureGalleryPermission",
  "CaptureType",
  "CatalogCategoryFilter",
  "CatalogSortAggregation",
  "CatalogSortType",
  "CellBlock",
  "CellMaterial",
  "CellOrientation",
  "CenterDialogType",
  "CharacterControlMode",
  "ChatCallbackType",
  "ChatColor",
  "ChatMode",
  "ChatPrivacyMode",
  "ChatRestrictionStatus",
  "ChatStyle",
  "ChatVersion",
  "ClientAnimatorThrottlingMode",
  "CloseReason",
  "CollaboratorStatus",
  "CollisionFidelity",
  "CommandPermission",
  "CompileTarget",
  "CompletionAcceptanceBehavior",
  "CompletionItemKind",
  "CompletionItemTag",
  "CompletionTriggerKind",
  "CompositeValueCurveType",
  "CompressionAlgorithm",
  "ComputerCameraMovementMode",
  "ComputerMovementMode",
  "ConfigSnapshotErrorState",
  "ConnectionError",
  "ConnectionState",
  "ContentSourceType",
  "ContextActionPriority",
  "ContextActionResult",
  "ControlMode",
  "CoreGuiType",
  "CreateAssetResult",
  "CreateContentResult",
  "CreateOutfitFailure",
  "CreatorType",
  "CreatorTypeFilter",
  "CurrencyType",
  "CustomCameraMode",
  "DataModelChangeType",
  "DataModelExtractorFileType",
  "DataStoreRequestType",
  "DebugBreakModeType",
  "DebuggerEndReason",
  "DebuggerExceptionBreakMode",
  "DebuggerFrameType",
  "DebuggerPauseReason",
  "DebuggerResumeType",
  "DebuggerStatus",
  "DefaultScriptSyncFileType",
  "DevCameraOcclusionMode",
  "DevComputerCameraMovementMode",
  "DevComputerMovementMode",
  "DevTouchCameraMovementMode",
  "DevTouchMovementMode",
  "DeveloperMemoryTag",
  "DeviceFeatureType",
  "DeviceForm",
  "DeviceLevel",
  "DeviceSimulatorScalingMode",
  "DeviceType",
  "DialogBehaviorType",
  "DialogPurpose",
  "DialogTone",
  "DigitsRigDescriptionSide",
  "DiscountType",
  "DisplayScalingMode",
  "DisplaySize",
  "DistanceAttenuationMode",
  "DomainType",
  "DominantAxis",
  "DraftStatusCode",
  "DragDetectorDragStyle",
  "DragDetectorPermissionPolicy",
  "DragDetectorResponseStyle",
  "DraggerCoordinateSpace",
  "DraggerMovementMode",
  "DraggingScrollBar",
  "EasingDirection",
  "EasingStyle",
  "EditableStatus",
  "ElasticBehavior",
  "EmitterPositionType",
  "EngagementLevel",
  "EngineFolder",
  "EnviromentalPhysicsThrottle",
  "ExperienceActivationStatus",
  "ExperienceAuthScope",
  "ExperienceEventStatus",
  "ExperienceStateCaptureSelectionMode",
  "ExperienceStateRecordingLoadMode",
  "ExperienceStateRecordingLoadSourceType",
  "ExperienceStateRecordingPlaybackMode",
  "ExplosionType",
  "ExternalEditorMode",
  "FACSDataLod",
  "FacialAgeEstimationResultType",
  "FacialAnimationStreamingState",
  "FacsActionUnit",
  "FeatureRestrictionAbuseVector",
  "FeedbackType",
  "FieldOfViewMode",
  "FillDirection",
  "FilterErrorType",
  "FilterResult",
  "FilterType",
  "FinishRecordingOperation",
  "FluidFidelity",
  "FluidForces",
  "Font",
  "FontSize",
  "FontStyle",
  "FontWeight",
  "ForceLimitMode",
  "FormFactor",
  "FrameStyle",
  "FramerateManagerMode",
  "FriendRequestEvent",
  "FriendStatus",
  "FriendsCallingEndReason",
  "FriendsCallingParticipantErrors",
  "FriendsCallingParticipantLeaveReason",
  "FriendsCallingParticipantStatus",
  "FriendsCallingPhase",
  "FrustumStreamingMode",
  "FunctionalTestResult",
  "GameAvatarType",
  "GamepadType",
  "GearGenreSetting",
  "GearType",
  "GenerateMomentTextResult",
  "Genre",
  "GradientTileMode",
  "GradientType",
  "GraphicsMode",
  "GraphicsOptimizationMode",
  "GroupMembershipStatus",
  "GuiState",
  "GuiType",
  "HandlesStyle",
  "HapticEffectType",
  "HashAlgorithm",
  "HighlightDepthMode",
  "HorizontalAlignment",
  "HoverAnimateSpeed",
  "HttpCachePolicy",
  "HttpCompression",
  "HttpContentType",
  "HttpError",
  "HttpRequestType",
  "HumanoidCollisionType",
  "HumanoidDisplayDistanceType",
  "HumanoidHealthDisplayType",
  "HumanoidRigType",
  "HumanoidStateType",
  "IKCollisionsMode",
  "IKControlConstraintSupport",
  "IKControlType",
  "IXPLoadingStatus",
  "ImageAlphaType",
  "ImageCombineType",
  "InOut",
  "InfoType",
  "InitialDockState",
  "InputActionType",
  "InputBindingType",
  "InputSink",
  "InputType",
  "InstanceFileSyncStatus",
  "IntentReplicability",
  "IntermediateMeshGenerationResult",
  "InternalVideoUsage",
  "InterpolationThrottlingMode",
  "InviteState",
  "ItemLineAlignment",
  "JoinSource",
  "JointCreationMode",
  "KeyCode",
  "KeyCodeStringFormat",
  "KeyInterpolationMode",
  "KeywordFilterType",
  "KnownWindow",
  "LeftRight",
  "LexemeType",
  "LightingStyle",
  "Limb",
  "LineJoinMode",
  "ListDisplayMode",
  "ListenerLocation",
  "ListenerPositionType",
  "ListenerType",
  "LiveEditingAtomicUpdateResponse",
  "LiveEditingBroadcastMessageType",
  "LoadCharacterLayeredClothing",
  "LoadDynamicHeads",
  "LocationType",
  "LuauTypeCheckMode",
  "MakeupType",
  "MarketplaceBulkPurchasePromptStatus",
  "MarketplaceItemPurchaseStatus",
  "MarketplaceProductType",
  "MarkupKind",
  "MatchmakingType",
  "Material",
  "MaterialPattern",
  "MembershipType",
  "MergeResolution",
  "MergeStatus",
  "MeshAttribute",
  "MeshPartDetailLevel",
  "MeshPartHeadsAndAccessories",
  "MeshScaleUnit",
  "MeshType",
  "MessageType",
  "ModelLevelOfDetail",
  "ModelStreamingBehavior",
  "ModelStreamingMode",
  "ModerationResultCategory",
  "ModerationResultLabel",
  "ModerationStatus",
  "ModifierKey",
  "MouseBehavior",
  "MoveState",
  "MuteState",
  "NameOcclusion",
  "NegateOperationHiddenHistory",
  "NetworkOwnership",
  "NetworkStatus",
  "NoiseType",
  "NormalId",
  "NotificationButtonType",
  "OperationType",
  "OrientationAlignmentMode",
  "OutfitSource",
  "OutfitType",
  "OutputLayoutMode",
  "OverrideMouseIconBehavior",
  "PackagePermission",
  "PageMilestoneType",
  "PageType",
  "PartType",
  "ParticleEmitterShape",
  "ParticleEmitterShapeInOut",
  "ParticleEmitterShapeStyle",
  "ParticleFlipbookLayout",
  "ParticleFlipbookMode",
  "ParticleFlipbookTextureCompatible",
  "ParticleOrientation",
  "PathStatus",
  "PathWaypointAction",
  "PathfindingUseImprovedSearch",
  "PeoplePageLayout",
  "PerformanceOverlayMode",
  "PermissionLevelShown",
  "PhysicalConstraintType",
  "PhysicsSimulationRate",
  "PhysicsSteppingMethod",
  "PinExperienceStatus",
  "PioneerSource",
  "PlaceContentPreference",
  "PlacePublishType",
  "Platform",
  "PlaybackState",
  "PlayerActions",
  "PlayerCharacterDestroyBehavior",
  "PlayerChatType",
  "PlayerDataErrorState",
  "PlayerDataLoadFailureBehavior",
  "PlayerExitReason",
  "PlayerPlatformActivationStatus",
  "PlayerPlatformSpenderStatus",
  "PluginConnectionTargetType",
  "PoseEasingDirection",
  "PoseEasingStyle",
  "PositionAlignmentMode",
  "PredictionMode",
  "PredictionStatus",
  "PredictiveStreamingMode",
  "PreferredInput",
  "PreferredTextSize",
  "PrefetchDownloadStatus",
  "PrimalPhysicsSolver",
  "PrimitiveType",
  "PrivilegeType",
  "ProductLocationRestriction",
  "ProductPurchaseChannel",
  "ProductPurchaseDecision",
  "ProjectServiceOperationResult",
  "PromptCreateAssetResult",
  "PromptCreateAvatarResult",
  "PromptCreateOutfitResult",
  "PromptCreatePlatformContentResult",
  "PromptExperienceDetailsResult",
  "PromptLinkSharingResult",
  "PromptPublishAssetResult",
  "PropertyStatus",
  "ProximityPromptExclusivity",
  "ProximityPromptInputType",
  "ProximityPromptStyle",
  "PurchaseOption",
  "QualityLevel",
  "QueueDecision",
  "R15CollisionType",
  "RaycastFilterType",
  "ReadCapturesFromGalleryResult",
  "ReceiptDecision",
  "ReceiptType",
  "RecommendationActionType",
  "RecommendationDepartureIntent",
  "RecommendationImpressionType",
  "RecommendationItemContentType",
  "RecommendationItemVisibility",
  "RecommendationPreferenceTargetType",
  "RecommendationPreferenceType",
  "RejectCharacterDeletions",
  "RenderFidelity",
  "RenderPriority",
  "RenderingCacheOptimizationMode",
  "RenderingTestComparisonMethod",
  "ReplicateInstanceDestroySetting",
  "ResamplerMode",
  "ReservedHighlightId",
  "RestPose",
  "RestPoseModel",
  "ReturnKeyType",
  "ReverbType",
  "ReviewableContentState",
  "RibbonTool",
  "RigLabel",
  "RigScale",
  "RigType",
  "RollOffMode",
  "RolloutState",
  "RotationOrder",
  "RotationType",
  "RsvpStatus",
  "RtlTextSupport",
  "RunContext",
  "RunState",
  "RuntimeUndoBehavior",
  "SafeAreaCompatibility",
  "SalesTypeFilter",
  "SandboxedInstanceMode",
  "SaveAvatarThumbnailCustomizationFailure",
  "SaveFilter",
  "SavedQualitySetting",
  "ScaleType",
  "ScopeCheckResult",
  "ScreenInsets",
  "ScreenOrientation",
  "ScreenshotCaptureResult",
  "ScriptScannerUpdateType",
  "ScriptStoppedReason",
  "ScriptVariableScope",
  "ScrollBarInset",
  "ScrollState",
  "ScrollingDirection",
  "SecurityCapability",
  "SelectionBehavior",
  "SelectionRenderMode",
  "SelfViewPosition",
  "SensorMode",
  "SensorUpdateType",
  "ServerLiveEditingMode",
  "ServiceVisibility",
  "Severity",
  "ShowAdResult",
  "SignalBehavior",
  "SimulationMode",
  "SizeConstraint",
  "SlimTintMode",
  "SlimTranscoderStatus",
  "SlimViewContext",
  "SolverConvergenceMetricType",
  "SolverConvergenceVisualizationMode",
  "SortDirection",
  "SortOrder",
  "SpecialKey",
  "StartCorner",
  "StateObjectFieldType",
  "StateReferenceFrame",
  "Status",
  "StepFrequency",
  "StreamOutBehavior",
  "StreamingIntegrityMode",
  "StreamingPauseMode",
  "StrokeSizingMode",
  "StudioAction",
  "StudioCaptureBufferStatus",
  "StudioCaptureScreenshotFormat",
  "StudioCloseMode",
  "StudioDataModelType",
  "StudioPlaceUpdateFailureReason",
  "StudioScriptEditorColorCategories",
  "StudioScriptEditorColorPresets",
  "StudioStyleGuideColor",
  "StudioStyleGuideModifier",
  "Style",
  "SubscriptionExpirationReason",
  "SubscriptionPaymentStatus",
  "SubscriptionPeriod",
  "SubscriptionState",
  "SurfaceConstraint",
  "SurfaceGuiShape",
  "SurfaceGuiSizingMode",
  "SurfaceType",
  "SwipeDirection",
  "SystemThemeValue",
  "TableMajorAxis",
  "TeamCreateErrorState",
  "Technology",
  "TelemetryBackend",
  "TelemetryStandardizedField",
  "TeleportMethod",
  "TeleportResult",
  "TeleportState",
  "TeleportType",
  "TerrainAcquisitionMethod",
  "TerrainFace",
  "TerrainLiquidMergeOperation",
  "TerrainSolidMergeOperation",
  "TextChannelDisplayMode",
  "TextChatMessageStatus",
  "TextDirection",
  "TextFilterContext",
  "TextInputType",
  "TextTruncate",
  "TextXAlignment",
  "TextYAlignment",
  "TextureMode",
  "TextureQueryType",
  "ThreadPoolConfig",
  "ThrottlingPriority",
  "ThumbnailSize",
  "ThumbnailType",
  "TickCountSampleMethod",
  "TitleBarControlsPosition",
  "TitleBarMode",
  "TonemapperPreset",
  "TopBottom",
  "TouchCameraMovementMode",
  "TouchMovementMode",
  "TrackerError",
  "TrackerExtrapolationFlagMode",
  "TrackerFaceTrackingStatus",
  "TrackerLodFlagMode",
  "TrackerLodValueMode",
  "TrackerMode",
  "TrackerPromptEvent",
  "TrackerType",
  "TriStateBoolean",
  "TweenStatus",
  "UICaptureMode",
  "UIDragDetectorBoundingBehavior",
  "UIDragDetectorDragRelativity",
  "UIDragDetectorDragSpace",
  "UIDragDetectorDragStyle",
  "UIDragDetectorResponseStyle",
  "UIDragSpeedAxisMapping",
  "UIFlexAlignment",
  "UIFlexMode",
  "UITheme",
  "UiMessageType",
  "UpdateState",
  "UploadCaptureResult",
  "UsageContext",
  "UserAcquisitionSource",
  "UserCFrame",
  "UserIdMode",
  "UserInputState",
  "UserInputType",
  "UserNewReturningStatus",
  "UserReturnStatus",
  "VRComfortSetting",
  "VRControllerModelMode",
  "VRDeviceType",
  "VRLaserPointerMode",
  "VRSafetyBubbleMode",
  "VRScaling",
  "VRSessionState",
  "VRTouchpad",
  "VRTouchpadMode",
  "VelocityConstraintMode",
  "VerifiedLevel",
  "VerticalAlignment",
  "VerticalScrollBarPosition",
  "VibrationMotor",
  "VideoCaptureResult",
  "VideoCaptureStartedResult",
  "VideoDeviceCaptureQuality",
  "VideoError",
  "VideoSampleSize",
  "ViewMode",
  "VirtualCursorMode",
  "VirtualInputMode",
  "VoiceChatDistanceAttenuationType",
  "VoiceChatState",
  "VoiceClientLeaveReasons",
  "VoiceControlPath",
  "VoiceRccReconnectReason",
  "VolumetricAudio",
  "WaterDirection",
  "WaterForce",
  "WebSocketState",
  "WebStreamClientState",
  "WebStreamClientType",
  "WeldConstraintPreserve",
  "WhenUserFirstPlayed",
  "WhisperChatPrivacyMode",
  "WindSoundProfile",
  "WindowState",
  "WrapLayerAutoSkin",
  "WrapLayerDebugMode",
  "WrapTargetDebugMode",
  "ZIndexBehavior",
}

DataTypes = {
  "AdReward",
  "AnimTrackMetadata",
  "AnimTrackPlayState",
  "AnimTrackWeight",
  "AssetContentMap",
  "Axes",
  "BinaryString",
  "BrickColor",
  "CFrame",
  "CSGPropertyData",
  "CatalogSearchParams",
  "ClipEvaluator",
  "CollectionHandle",
  "Color3",
  "Color3uint8",
  "ColorSequence",
  "Content",
  "ContentId",
  "CoordinateFrame",
  "DateTime",
  "DockWidgetPluginGuiInfo",
  "Faces",
  "FacsReplicationData",
  "FloatCurveKey",
  "Font",
  "Function",
  "InstanceRef",
  "Instances",
  "NetAssetRef",
  "NumberRange",
  "NumberSequence",
  "OpenCloudModel",
  "OptionalCoordinateFrame",
  "OverlapParams",
  "Path2DControlPoint",
  "PhysicalProperties",
  "ProtectedString",
  "QDir",
  "QFont",
  "RBXScriptConnection",
  "RBXScriptSignal",
  "Ray",
  "RaycastParams",
  "RaycastResult",
  "Rect",
  "Region3",
  "Region3int16",
  "ReplicationPV",
  "RotationCurveKey",
  "ScopedInstanceIdentity",
  "Secret",
  "SecurityCapabilities",
  "SharedString",
  "SharedTable",
  "SystemAddress",
  "TweenInfo",
  "UDim",
  "UDim2",
  "UniqueId",
  "User",
  "ValueCurveKey",
  "Vector2",
  "Vector3",
  "Vector3int16",
  "WebViewParams",
  "buffer",
  -- Group
  "Array",
  "Dictionary",
  "Map",
  "Tuple",
  "Variant",
  -- Primitive
  "bool",
  "double",
  "float",
  "int",
  "int64",
  "null",
  "string",
}

Globals = {
  "assert",
  "collectgarbage",
  "DebuggerManager",
  "delay",
  "elapsedTime",
  "Enum",
  "error",
  "game",
  "gcinfo",
  "getfenv",
  "getmetatable",
  "ipairs",
  "loadstring",
  "newproxy",
  "next",
  "pairs",
  "pcall",
  "plugin",
  "PluginManager",
  "print",
  "printidentity",
  "rawequal",
  "rawget",
  "rawlen",
  "rawset",
  "require",
  "script",
  "select",
  "setfenv",
  "setmetatable",
  "settings",
  "shared",
  "spawn",
  "stats",
  "tick",
  "time",
  "tonumber",
  "tostring",
  "type",
  "typeof",
  "unpack",
  "UserSettings",
  "version",
  "wait",
  "warn",
  "workspace",
  "xpcall",
  "ypcall",
  "_G",
  "_VERSION",
}

Keywords = {
  "if",
  "else",
  "elseif",
  "export",
  "for",
  "while",
  "break",
  "continue",
  "repeat",
  "until",
  "next",
  "not",
  "then",
  "end",
  "function",
  "local",
  "or",
  "and",
  "do",
  "self",
  "type",
  "typeof",
}

sUNC = {
  -- Closures
  "checkcaller",
  "clonefunction",
  "getfunctionhash",
  "hookfunction",
  "hookmetamethod",
  "iscclosure",
  "isexecutorclosure",
  "islclosure",
  "loadstring",
  "newcclosure",
  "restorefunction",
  -- Debugs
  "debug.getconstant",
  "debug.getconstants",
  "debug.getproto",
  "debug.getprotos", 
  "debug.getstack",
  "debug.getupvalue",
  "debug.getupvalues",
  "debug.setconstant",
  "debug.setstack",
  "debug.setupvalue",
  -- Drawing
  "cleardrawcache",
  "getrenderproperty",
  "isrenderproperty",
  "setrenderpropertt",
  -- Encoding
  "base64decode",
  "base64encode",
  "lz4compress",
  "lz4encompress",
  -- Enviroment
  "getgc",
  "getgenv",
  "getreg",
  "getrenv",
  -- Filesystem
  "writefile",
  "readfile",
  "appendfile",
  "listfiles",
  "delfile",
  "delfolder",
  "isfile",
  "isfolder",
  "makefolder",
  "loadfile",
  "getcustomasset",
  -- Instances
  "cloneref",
  "compareinstances",
  "fileclickdetector",
  "fireproimitprompt",
  "firetouchinterest",
  "getcallbackvalue",
  "gethui",
  "getinstances",
  "getnilinstances",
  -- Metatable
  "getnamecallmethod",
  "getrawmetatable",
  "isreadonly",
  "setrawmetatable",
  "setreadonly",
  -- Miscelianeous
  "identifyexecutor",
  "request",
  -- Reflection
  "gethiddenproperty",
  "getthreadidentity",
  "isscriptable",
  "sethiddenproperty",
  "setscriptable",
  "setthreadidentity",
  -- Scripts
  "getcallingscript",
  "getloadedmodules",
  "getrunningscripts",
  "getscriptbytecode",
  "getscriptclosure",
  "getscriptfromthread",
  "getscripthash",
  "getscripts",
  "getsenv",
  -- Signal
  "firesignal",
  "getconnections",
  "relicatesignal",
  -- WebSocket
  "WebSocket",
}

Special = {
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "0",
  "@",
  "#",
  "$",
  "&",
  "/",
  "*",
  '"',
  "'",
  "!",
  "?",
}

Comments = {
  "--",
  "[[]]",
}
---------------------------------------------------------------------------------------

local function Tween(obj, size, pos, backcol, tra, time)
    local tween = s.TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {Size = size,
        Position = pos,
        BackgroundColor3 = backcol,
        BackgroundTransparency = tra,
        }
    )

    tween:Play()
    return tween
end

local state = false
local menu = game:GetService("CoreGui"):WaitForChild("ExperienceSettings").Menu

local notif = Instance.new("Frame")
notif.Name = "Notification"
notif.ClipsDescendants = true
notif.Size = UDim2.new(1,0,0.4,0)
notif.Position = UDim2.new(0,0,0.11,0)
notif.BorderMode = Enum.BorderMode.Inset
notif.BorderSizePixel = 10
notif.BackgroundTransparency = 1
notif.Active = false
notif.Parent = menu
ListLayout(notif, 0,5,"HCenter","VTop","SLayout","FillV")


local function ding(txt, time, R, G, B)
    local duration = tonumber(time)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.ClipsDescendants = true
    main.AutomaticSize = Enum.AutomaticSize.XY
    main.BackgroundTransparency = 1
    main.Active = false
    main.Parent = notif
    Corner(0,5,main)

    local scale = Instance.new("UIScale")
    scale.Scale = 0
    scale.Parent = main

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.ClipsDescendants = true
    body.AutomaticSize = Enum.AutomaticSize.XY
    body.BackgroundColor3 = Color3.new(0,0,0)
    body.BackgroundTransparency = 0.5
    body.BorderMode = Enum.BorderMode.Inset
    body.BorderSizePixel = 10
    body.Active = false
    body.ZIndex = 2
    body.Parent = main
    Corner(0,5,body)

    local s_body = Stroke(body, "ASMBorder", R or 255, G or 255, B or 255, "LJMRound", 2, 0)
    s_body.BorderStrokePosition = Enum.BorderStrokePosition.Inner

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.AutomaticSize = Enum.AutomaticSize.XY
    text.ZIndex = 2
    text.TextSize = 12
    text.TextWrapped = true
    text.RichText = true
    text.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    text.Text = txt == nil and "<b>Failed</b>: Uhm.. I forgot" or tostring(txt)
    text.Parent = body

    local timer = Instance.new("Frame")
    timer.Name = "Timer"
    timer.Size = UDim2.new(1,0,0,5)
    timer.Position = UDim2.new(0,0,1,-5)
    timer.BackgroundColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    timer.BorderSizePixel = 0
    timer.ZIndex = 2
    timer.Active = false
    timer.Parent = main

    -- Open: UIScale 0 -> 1
    s.TweenService:Create(
        scale,
        TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        {Scale = 1}
    ):Play()

    -- Countdown (nil or 0 = permanent)
    if duration and duration > 0 then
        local timerTween = s.TweenService:Create(
            timer,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0,0,0,5)}
        )

        timerTween:Play()

        task.delay(duration, function()
            if not main.Parent then
                return
            end

            -- Close: UIScale 1 -> 0
            local closeTween = s.TweenService:Create(
                scale,
                TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
                {Scale = 0}
            )

            closeTween:Play()
            closeTween.Completed:Wait()

            main:Destroy()
        end)
    end
end


local editor = menu.TopBar.Holder.a5_Editor

local eback = Instance.new("Frame")
eback.Name = "Editor"
eback.Position = UDim2.new(0.1,0,1.1,0)
eback.Size = UDim2.new(0.8,0,0.8,0)
eback.BorderMode = Enum.BorderMode.Inset
eback.BorderSizePixel = 5
eback.BackgroundColor3 = Color3.fromRGB(17,18,25)
eback.BackgroundTransparency = 1
eback.Active = false
eback.Parent = menu
Corner(0,8,eback)
ListLayout(eback, 0, 10, "HCenter", "VCenter", "SLayout", "FillV")

editor.MouseButton1Click:Connect(function()
  if state == true then
      editor.Image = "rbxassetid://73984153023004"
      state = false
      Tween(eback, nil, UDim2.new(0.1,0,1.1,0), nil,nil, 0.4)
  else
      editor.Image = "rbxassetid://108682872011804"
      state = true
      Tween(eback, nil, UDim2.new(0.1,0,0.18,0), nil,nil, 0.4)
  end
end)

task.spawn(function()
  local holder = menu.TopBar.Holder
	local function checkHolderSize()
		local x = holder.Size.X.Offset
		if x > 311 then
			editor.Visible = true
		else
			editor.Visible = false
		end
	end

	checkHolderSize()

	holder:GetPropertyChangedSignal("Size"):Connect(checkHolderSize)
end)

local can = Instance.new("Frame")
can.Name = "Page"
can.Size = UDim2.new(1,0,0.8,0)
can.BackgroundColor3 = eback.BackgroundColor3
can.BackgroundTransparency = 0.1
can.BorderMode = eback.BorderMode
can.BorderSizePixel = 10
can.Active = false
can.Parent = eback
Corner(0,8,can)

local bottombar = Instance.new("Frame")
bottombar.Name = "BottmBar"
bottombar.ClipsDescendants = true
bottombar.AutomaticSize = Enum.AutomaticSize.X
bottombar.Size = UDim2.new(0,0,0,50)
bottombar.BackgroundColor3 = eback.BackgroundColor3
bottombar.BackgroundTransparency = 0.1
bottombar.BorderMode = eback.BorderMode
bottombar.BorderSizePixel = 5
bottombar.Active = false
bottombar.Parent = eback
Corner(1, 0,bottombar)
ListLayout(bottombar, 0, 5, "HCenter", "VCenter", "SLayout", "FillH")

local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0,35,0,35)
icon.Position = UDim2.new(0,0,0,-50)
icon.BackgroundColor3 = eback.BackgroundColor3
icon.BackgroundTransparency = 0.1
icon.Image = "rbxassetid://76063966669126"
icon.Parent = can
Corner(0,8,icon)

local topic = Instance.new("TextLabel")
topic.Name = "Topic"
topic.Size = UDim2.new(0,200,0,35)
topic.Position = UDim2.new(0,40,0,-50)
topic.BackgroundColor3 = eback.BackgroundColor3
topic.BackgroundTransparency = 0.1
topic.Text = "<b>Unknow Page</b>"
topic.TextScaled = true
topic.TextColor3 = Color3.new(1,1,1)
topic.RichText = true
topic.BorderMode = eback.BorderMode
topic.BorderSizePixel = 5
topic.TextXAlignment = Enum.TextXAlignment.Left
topic.Parent = can
Corner(0,8,topic)

topic.Text = "<b>Information</b>"

local incan = Instance.new("Frame")
incan.Name = "InsideCanvas"
incan.ClipsDescendants = true
incan.Size = UDim2.new(1,0,1,0)
incan.BackgroundTransparency = 1
incan.BorderSizePixel = 0
incan.Active = false
incan.Parent = can

local incan2 = Instance.new("Frame")
incan2.Name = "SecondInsideCanvasNoClip"
incan2.Size = UDim2.new(1,0,1,0)
incan2.Position = UDim2.new(0,0,0,0)
incan2.BackgroundTransparency = 1
incan2.BorderSizePixel = 0
incan2.Active = false
incan2.Parent = incan
ListLayout(incan2, 0, 0, "HLeft", "VCenter", "SLayout", "FillH")

local pageButtons = {}

local function addpage(vtopic, vtopic2, image, udim2)
    local Frame = Instance.new("Frame")
    Frame.Name = tostring(vtopic)
    Frame.ClipsDescendants = false
    Frame.Active = false
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Parent = incan2

    local Button = Instance.new("ImageButton")
    Button.Name = tostring(vtopic)
    Button.Size = UDim2.new(0,40,0,40)
    Button.BackgroundColor3 = Color3.new(1,1,1)
    Button.BackgroundTransparency = 1
    Button.Image = "rbxassetid://" .. tonumber(image)
    Button.Parent = bottombar
    Corner(1,0,Button)

    table.insert(pageButtons, Button)

    Button.MouseButton1Click:Connect(function()
        for _, otherButton in ipairs(pageButtons) do
            Tween(otherButton, nil,nil,nil, 1, 0.2)
        end

        Tween(Button, nil,nil,nil, 0.5, 0.2)

        Tween(incan2, nil, udim2, nil,nil, 0.4)
        topic.Text = "<b>" .. tostring(vtopic2) .. "</b>"
        icon.Image = "rbxassetid://".. tonumber(image)
    end)

  return Frame
end

addpage("Test", "Information", 76063966669126, UDim2.new(0,0,0,0))
addpage("Editor", "Editor", 79382593376107, UDim2.new(-1,0,0,0))
addpage("Device", "Device Exeplorer", 77415773465628, UDim2.new(-2,0,0,0))
addpage("Dex", "Dex Exeplorer", 73941302443097, UDim2.new(-3,0,0,0))
addpage("PlayersList", "Learderboard", 133148371698132, UDim2.new(-4,0,0,0))
addpage("ServerList", "ServerList", 124257243656869, UDim2.new(-5,0,0,0))
addpage("Settings", "Settings", 109951202940492, UDim2.new(-6,0,0,0))
addpage("About", "About", 128234289075456, UDim2.new(-7,0,0,0))

local ic2 = {
  Test = incan2.Test,
  Editor = incan2.Editor,
  Device = incan2.Device,
  Dex = incan2.Dex,
  PlayersList = incan2.PlayersList,
  ServerList = incan2.ServerList,
  About = incan2.About,
}

local cs = Instance.new("TextLabel")
cs.Name = "ComingSoon"
cs.Size = UDim2.new(1,0,1,0)
cs.BackgroundTransparency = 1
cs.TextColor3 = Color3.new(1,1,1)
cs.TextScaled = true
cs.Text = "Underdevelopment, but Editor page is available, and another page will be available soon!"
cs.BorderMode = Enum.BorderMode.Inset
cs.BorderSizePixel = 100
cs.Visible = true
cs.Parent = ic2.Test

-- >> Editor << --

local e_ed = Instance.new("Frame")
e_ed.Name = "Editor"
e_ed.Active = false
e_ed.Size = UDim2.new(0.8,-5,0.8,-5)
e_ed.Position = UDim2.new(0.2,5,0,0)
e_ed.BackgroundTransparency = 1
e_ed.BorderMode = Enum.BorderMode.Inset
e_ed.BorderSizePixel = 5
e_ed.Parent = ic2.Editor

local e_sr = Instance.new("ScrollingFrame")
e_sr.Name = "EditorScroll"
e_sr.Size = UDim2.new(1,0,1,0)
e_sr.BorderMode = Enum.BorderMode.Inset
e_sr.BorderSizePixel = 5
e_sr.BackgroundColor3 = Color3.fromRGB(0,0,0)
e_sr.BorderColor3 = Color3.fromRGB(0,0,0)
e_sr.CanvasSize = UDim2.new(0,0,0,0)
e_sr.ScrollBarThickness = 5
e_sr.AutomaticCanvasSize = Enum.AutomaticSize.XY
e_sr.Parent = e_ed
Corner(0,8,e_sr)
ListLayout(e_sr,0,3,"HLeft","VTop","SLayout","FillH")

local linen = Instance.new("TextLabel")
linen.Name = "LineNumber"
linen.Position = UDim2.new(0,0,0,0)
linen.AutomaticSize = Enum.AutomaticSize.XY
linen.BorderMode = Enum.BorderMode.Inset
linen.Size = UDim2.new(0,0,0,0)
linen.AutomaticSize = Enum.AutomaticSize.XY
linen.BorderSizePixel = 5
linen.BorderColor3 = linen.BackgroundColor3
linen.TextSize = 14
linen.Text = ""
linen.Font = Enum.Font.Code
linen.TextXAlignment = Enum.TextXAlignment.Left
linen.TextYAlignment = Enum.TextYAlignment.Top
linen.TextColor3 = Color3.new(0,0,0)
linen.Parent = e_sr

local code = Instance.new("TextBox")
code.Name = "Code"
code.Position = UDim2.new(0,0,0,0)
code.Size = UDim2.new(0,0,0,0)
code.AutomaticSize = Enum.AutomaticSize.None
code.BackgroundTransparency = 1
code.BorderMode = Enum.BorderMode.Inset
code.BorderSizePixel = 5
code.TextSize = 14
code.Text = ""
code.TextXAlignment = Enum.TextXAlignment.Left
code.TextYAlignment = Enum.TextYAlignment.Top
code.TextColor3 = Color3.new(1,1,1)
code.Font = Enum.Font.Code
code.PlaceholderColor3 = Color3.new(0.5,0.5,0.5)
code.PlaceholderText = 'print("Hello, World!")'
code.MultiLine = true
code.ClearTextOnFocus = false
code.TextWrapped = false
code.Parent = e_sr

local syn = Instance.new("TextLabel")
syn.Name = "Syntax"
syn.Active = false
syn.Size = code.Size
syn.Position = UDim2.new(0,0,0,0)
syn.AutomaticSize = Enum.AutomaticSize.None
syn.BackgroundTransparency = 1
syn.RichText = true
syn.TextSize = code.TextSize
syn.Text = ""
syn.TextXAlignment = code.TextXAlignment
syn.TextYAlignment = code.TextYAlignment
syn.TextColor3 = code.TextColor3
syn.Font = code.Font
syn.TextWrapped = code.TextWrapped
syn.ClipsDescendants = false
syn.Parent = code

loc.SyntaxEnabled = true
loc.SyntaxEditing = false

-- Keep the RichText layer aligned with the editable Code while it is focused.
-- The ScrollingFrame handles the actual editor scrolling; the syntax layer follows
-- the same origin during editing and returns to the normal origin afterward.
loc.SyncSyntaxScroll = function()
    if loc.SyntaxEditing then
        syn.Position = UDim2.new(0,0,0,0)
    else
        syn.Position = UDim2.new(0,0,0,0)
    end
end

loc.ApplySyntaxMode = function()
    if loc.SyntaxMode == "OFF" then
        code.TextTransparency = 0
        syn.Visible = false
    elseif loc.SyntaxMode == "ON" then
        code.TextTransparency = 1
        syn.Visible = true
    else -- Edit Only
        if loc.SyntaxEditing then
            code.TextTransparency = 0
            syn.Visible = false
        else
            code.TextTransparency = 1
            syn.Visible = true
        end
    end
end

code.Focused:Connect(function()
    loc.SyntaxEditing = true
    loc.ApplySyntaxMode()
    task.defer(loc.SyncSyntaxScroll)
end)

code.FocusLost:Connect(function()
    loc.SyntaxEditing = false
    syn.Position = UDim2.new(0,0,0,0)
    loc.ApplySyntaxMode()
end)

loc.SyntaxColors = {
    Classes = "rgb(255,80,80)",
    Enums = "rgb(255,165,0)",
    DataTypes = "rgb(255,105,180)",
    Globals = "rgb(0,255,255)",
    Keywords = "rgb(170,85,255)",
    sUNC = "rgb(255,255,0)",
    Special = "rgb(0,255,127)",
    Comments = "rgb(128,128,128)",
}

loc.SyntaxLookup = {}
loc.SyntaxMultiTokens = {}
loc.SyntaxSpecialTokens = {}

-- Priority resolves names that appear in more than one API category.
local syntaxCategories = {"Keywords", "sUNC", "Classes", "Enums", "DataTypes", "Globals"}
local syntaxSources = {
    Classes = Classes,
    Enums = Enums,
    DataTypes = DataTypes,
    Globals = Globals,
    Keywords = Keywords,
    sUNC = sUNC,
}

for _, category in ipairs(syntaxCategories) do
    local source = syntaxSources[category]
    if type(source) == "table" then
        for _, name in ipairs(source) do
            if type(name) == "string" and #name > 0 then
                if name:match("^[%a_][%w_]*$") then
                    if loc.SyntaxLookup[name] == nil then
                        loc.SyntaxLookup[name] = category
                    end
                else
                    loc.SyntaxMultiTokens[#loc.SyntaxMultiTokens + 1] = {
                        Token = name,
                        Category = category,
                    }
                end
            end
        end
    end
end

if type(Special) == "table" then
    for _, token in ipairs(Special) do
        if type(token) == "string" and #token > 0 then
            loc.SyntaxSpecialTokens[#loc.SyntaxSpecialTokens + 1] = token
        end
    end
end

table.sort(loc.SyntaxMultiTokens, function(a, b)
    return #a.Token > #b.Token
end)

table.sort(loc.SyntaxSpecialTokens, function(a, b)
    return #a > #b
end)

local function richEscape(value)
    return tostring(value or "")
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
end

local function richColor(value, category)
    return '<font color="' .. loc.SyntaxColors[category] .. '">' .. richEscape(value) .. '</font>'
end

local function longBracketEnd(source, startPos)
    if source:sub(startPos, startPos) ~= "[" then return nil end

    local pos = startPos + 1
    while source:sub(pos, pos) == "=" do
        pos += 1
    end

    if source:sub(pos, pos) ~= "[" then return nil end

    local close = "]" .. string.rep("=", pos - startPos - 1) .. "]"
    local finish = source:find(close, pos + 1, true)
    return finish and finish + #close - 1 or #source
end

local function isIdentifierStart(char)
    if not char or char == "" then return false end
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) or byte == 95
end

local function isIdentifierChar(char)
    if not char or char == "" then return false end
    local byte = string.byte(char)
    return (byte >= 65 and byte <= 90)
        or (byte >= 97 and byte <= 122)
        or (byte >= 48 and byte <= 57)
        or byte == 95
end

local function multiTokenMatch(source, pos)
    for _, item in ipairs(loc.SyntaxMultiTokens) do
        local token = item.Token
        if source:sub(pos, pos + #token - 1) == token then
            local before = source:sub(pos - 1, pos - 1)
            local after = source:sub(pos + #token, pos + #token)
            if (before == "" or not isIdentifierChar(before))
                and (after == "" or not isIdentifierChar(after)) then
                return token, item.Category
            end
        end
    end
end

local function specialTokenMatch(source, pos, length)
    for _, token in ipairs(loc.SyntaxSpecialTokens) do
        if pos + #token - 1 <= length and source:sub(pos, pos + #token - 1) == token then
            return token
        end
    end
end

local function readQuotedString(source, startPos, length, quote)
    local finish = startPos + 1
    local escaped = false

    while finish <= length do
        local char = source:sub(finish, finish)
        if escaped then
            escaped = false
        elseif char == "\\" then
            escaped = true
        elseif char == quote then
            return finish
        end
        finish += 1
    end

    return length
end

loc.SyncSyntaxRender = function()
    syn.Size = code.Size
    syn.Position = UDim2.new(0,0,0,0)
    syn.TextSize = code.TextSize
    syn.Font = code.Font
    syn.TextXAlignment = code.TextXAlignment
    syn.TextYAlignment = code.TextYAlignment
    syn.TextWrapped = code.TextWrapped
    syn.TextScaled = code.TextScaled
    syn.TextColor3 = code.TextColor3
end

loc.SyncEditorSize = function()
    local source = tostring(code.Text or "")
    local lines = string.split(source, "\n")
    local maxWidth = 1
    local lineHeight = s.TextService:GetTextSize("A", code.TextSize, code.Font, Vector2.new(100000, 100000)).Y

    for _, line in ipairs(lines) do
        local measured = s.TextService:GetTextSize(line == "" and " " or line, code.TextSize, code.Font, Vector2.new(100000, 100000))
        maxWidth = math.max(maxWidth, measured.X)
    end

    -- Keep the editable Code area at least as large as the visible editor.
    -- It can still grow beyond the viewport when the source becomes larger.
    local viewportWidth = math.max(1, e_sr.AbsoluteSize.X)
    local viewportHeight = math.max(1, e_sr.AbsoluteSize.Y)
    local width = math.max(math.ceil(maxWidth + 10), math.ceil(viewportWidth))
    local height = math.max(lineHeight * #lines + 2, code.TextSize + 2, math.ceil(viewportHeight))

    code.Size = UDim2.new(0, width, 0, math.ceil(height))
    syn.Size = code.Size
    code.Position = UDim2.new(0,0,0,0)
    syn.Position = UDim2.new(0,0,0,0)
end

e_sr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    task.defer(loc.SyncEditorSize)
end)

e_sr:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if loc.SyntaxEditing then
        task.defer(loc.SyncSyntaxScroll)
    end
end)

loc.UpdateSyntax = function()
    local source = tostring(code.Text or "")
    local output = {}
    local pos = 1
    local length = #source

    while pos <= length do
        local two = source:sub(pos, pos + 1)
        local one = source:sub(pos, pos)

        -- Comments always win before strings/API tokens.
        if two == "--" then
            local commentEnd
            if source:sub(pos + 2, pos + 2) == "[" then
                commentEnd = longBracketEnd(source, pos + 2)
            end

            if commentEnd then
                output[#output + 1] = richColor(source:sub(pos, commentEnd), "Comments")
                pos = commentEnd + 1
            else
                local lineEnd = source:find("\n", pos, true)
                local finish = lineEnd and (lineEnd - 1) or length
                if finish >= pos then
                    output[#output + 1] = richColor(source:sub(pos, finish), "Comments")
                end
                pos = lineEnd or (length + 1)
            end

        -- Strings are rendered as one complete token, including both quotes.
        elseif one == '"' or one == "'" or one == "`" then
            local finish = readQuotedString(source, pos, length, one)
            output[#output + 1] = richColor(source:sub(pos, finish), "Special")
            pos = finish + 1

        -- Preserve long-bracket text exactly. Long-bracket comments were
        -- already consumed by the comment branch above.
        elseif one == "[" then
            local finish = longBracketEnd(source, pos)
            if finish then
                output[#output + 1] = richEscape(source:sub(pos, finish))
                pos = finish + 1
            else
                output[#output + 1] = richEscape(one)
                pos += 1
            end

        else
            local multiToken, multiCategory = multiTokenMatch(source, pos)

            if multiToken then
                output[#output + 1] = richColor(multiToken, multiCategory)
                pos += #multiToken
            elseif isIdentifierStart(one) then
                local finish = pos + 1
                while finish <= length and isIdentifierChar(source:sub(finish, finish)) do
                    finish += 1
                end

                local word = source:sub(pos, finish - 1)
                local category = loc.SyntaxLookup[word]
                if category then
                    output[#output + 1] = richColor(word, category)
                else
                    output[#output + 1] = richEscape(word)
                end
                pos = finish
            else
                local specialToken = specialTokenMatch(source, pos, length)
                if specialToken then
                    output[#output + 1] = richColor(specialToken, "Special")
                    pos += #specialToken
                else
                    output[#output + 1] = richEscape(one)
                    pos += 1
                end
            end
        end
    end

    loc.SyncEditorSize()
    syn.Text = table.concat(output)
    loc.SyncSyntaxRender()
    loc.ApplySyntaxMode()
end

-- The TextBox stays visible for input/cursor/selection.
-- Its visibility/transparency is controlled by ApplySyntaxMode().
-- The render layer is allowed outside the TextBox content box so the last glyph is not clipped.
code.ClipsDescendants = false
syn.ClipsDescendants = false


-- Line numbers follow source lines only. AutomaticSize handles the UI size.
loc.UpdateLineNumbers = function()
    local text = tostring(code.Text or "")
    local count = math.max(1, select(2, text:gsub("\n", "")) + 1)
    local lines = {}
    for i = 1, count do
        lines[i] = tostring(i)
    end
    linen.Text = table.concat(lines, "\n")
end

loc.AutoSaveVersion = 0
loc.AutoSaveLoading = false

code:GetPropertyChangedSignal("Text"):Connect(function()
    task.defer(loc.UpdateLineNumbers)
    task.defer(loc.UpdateSyntax)

    if loc.AutoSaveLoading or not loc.SelectedTab then return end

    local currentTab = loc.SelectedTab
    local path = currentTab:GetAttribute("FilePath")
    local id = currentTab:GetAttribute("ScriptID")
    if not path or path == "" or not id or not isfile(path) then return end

    loc.AutoSaveVersion = loc.AutoSaveVersion + 1
    local version = loc.AutoSaveVersion

    task.delay(0.15, function()
        if version ~= loc.AutoSaveVersion then return end
        if loc.SelectedTab ~= currentTab then return end
        local currentPath = currentTab:GetAttribute("FilePath")
        local currentID = currentTab:GetAttribute("ScriptID")
        if currentPath and currentPath ~= "" and currentID and isfile(currentPath) then
            pcall(writefile, currentPath, loc.WithScriptID(code.Text, currentID))
        end
    end)
end)

local e_cs

local e_ba = Instance.new("Frame")
e_ba.Name = "EditorBar"
e_ba.Size = UDim2.new(0,195,0,40)
e_ba.Position = UDim2.new(1,-250,1,-50)
e_ba.BorderMode = Enum.BorderMode.Inset
e_ba.BorderSizePixel = 5
e_ba.BackgroundColor3 = Color3.fromRGB(255,255,255)
e_ba.BackgroundTransparency = 0.3
e_ba.Parent = e_ed
Corner(1,0,e_ba)
ListLayout(e_ba,0,3,"HCenter","VCenter","SLayout","FillH")

local e_mo2 = Instance.new("ScrollingFrame")
e_mo2.Name = "EditorMore"
e_mo2.Size = UDim2.new(0,245,1, -60)
e_mo2.Position = UDim2.new(1, -255, 0, 5)
e_mo2.BackgroundColor3 = Color3.fromRGB(255,255,255)
e_mo2.BackgroundTransparency = 0.3
e_mo2.Visible = false
e_mo2.BorderMode = Enum.BorderMode.Inset
e_mo2.BorderSizePixel = 5
e_mo2.CanvasSize = UDim2.new(0,0,0,0)
e_mo2.AutomaticCanvasSize = Enum.AutomaticSize.Y
e_mo2.ScrollingDirection = Enum.ScrollingDirection.Y
e_mo2.ScrollBarThickness = 0
e_mo2.ZIndex = 1
e_mo2.Parent = e_ed
Corner(0,5,e_mo2)
ListLayout(e_mo2,0,3,"HLeft","VTop","SLayout","FillV")

--====== EDITOR STORAGE ======--
loc.EditorRoot = "ExperienceSettings/Editor"
loc.TabsRoot = loc.EditorRoot .. "/Tabs"
loc.AutoExecuteRoot = loc.EditorRoot .. "/AutoExecute"
loc.DraftPath = loc.TabsRoot .. "/Draft.json"
loc.DefaultBackgroundColor3 = "79,79,79"
loc.DefaultTextColor3 = "255,255,255"
loc.DirectTarget = "Tab"
loc.SelectedTab = nil
loc.hide_e_ba = false
loc.MaxOutputs = 250
loc.Draft = {Scripts = {}}

if not isfolder("ExperienceSettings") then makefolder("ExperienceSettings") end
if not isfolder(loc.EditorRoot) then makefolder(loc.EditorRoot) end
if not isfolder(loc.TabsRoot) then makefolder(loc.TabsRoot) end
if not isfolder(loc.AutoExecuteRoot) then makefolder(loc.AutoExecuteRoot) end

function loc.SafeFileName(name)
    name = tostring(name or ""):gsub("[\\/:*?\"<>|]", "_"):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Script.lua" end
    if not name:lower():match("%.lua$") then name = name .. ".lua" end
    return name
end

function loc.NewScriptID()
    return s.HttpService:GenerateGUID(false):gsub("-", "")
end

function loc.ValidScriptID(id)
    return type(id) == "string" and id:match("^[%w]+$") ~= nil
end

function loc.ReadScriptID(text)
    return tostring(text or ""):match("^%-%- ScriptID:%s*(%S+)")
end

function loc.WithScriptID(text, id)
    text = tostring(text or "")
    if loc.ReadScriptID(text) then
        return (text:gsub("^%-%- ScriptID:%s*%S+", "-- ScriptID: " .. id, 1))
    end
    return "-- ScriptID: " .. id .. "\n" .. text
end

function loc.StripScriptID(text)
    return (tostring(text or ""):gsub("^%-%- ScriptID:%s*%S+%s*\n?", "", 1))
end

function loc.ParseRGB(text, fallback)
    local a,b,c = tostring(text or ""):match("^%s*(%-?%d+)%s*,%s*(%-?%d+)%s*,%s*(%-?%d+)%s*$")
    if not a then return fallback end
    return Color3.fromRGB(
        math.clamp(tonumber(a), 0, 255),
        math.clamp(tonumber(b), 0, 255),
        math.clamp(tonumber(c), 0, 255)
    )
end

function loc.LoadDraft()
    if isfile(loc.DraftPath) then
        local ok, data = pcall(function()
            return s.HttpService:JSONDecode(readfile(loc.DraftPath))
        end)
        if ok and type(data) == "table" and type(data.Scripts) == "table" then
            loc.Draft = data
            return
        end
    end
    loc.Draft = {Scripts = {}}
end

function loc.SaveDraft()
    pcall(function()
        writefile(loc.DraftPath, s.HttpService:JSONEncode(loc.Draft))
    end)
end

function loc.FindMeta(id)
    for _, data in ipairs(loc.Draft.Scripts) do
        if data.ScriptID == id then return data end
    end
end

function loc.RemoveMeta(id)
    for i = #loc.Draft.Scripts, 1, -1 do
        if loc.Draft.Scripts[i].ScriptID == id then
            table.remove(loc.Draft.Scripts, i)
            return
        end
    end
end

function loc.UpdateSaveRows()
    local hasFile = loc.SelectedTab ~= nil
    if loc.SaveUI then loc.SaveUI.Frame.Visible = not hasFile end
    if loc.SaveAsUI then loc.SaveAsUI.Frame.Visible = hasFile end
end

function loc.GetDirectSource()
    if loc.DirectTarget == "File" and loc.SelectedTab then
        local path = loc.SelectedTab:GetAttribute("FilePath")
        if path and path ~= "" and isfile(path) then
            return loc.StripScriptID(readfile(path))
        end
    end
    return code.Text
end

function loc.RunDirect(silent)
    local fn, err = loadstring(loc.GetDirectSource())
    if not fn then
        if not silent then ding("<b>Debug</b>: " .. tostring(err), 4, 255, 0, 0) end
        return
    end
    local ok, runErr = pcall(fn)
    if not silent then
        ding(ok and "<b>Execute</b>: Success" or "<b>Execute</b>: " .. tostring(runErr), 4, ok and 0 or 255, ok and 255 or 0, 0)
    end
end

function loc.DebugDirect()
    local fn, err = loadstring(loc.GetDirectSource())
    ding(fn and "<b>Debug</b>: Syntax OK" or "<b>Debug</b>: " .. tostring(err), 4, fn and 0 or 255, fn and 255 or 0, 255)
end

function loc.CopyDirect(silent)
    if setclipboard then
        local ok = pcall(setclipboard, loc.StripScriptID(loc.GetDirectSource()))
        if not silent then
            ding(ok and "<b>Copy</b>: Success" or "<b>Copy</b>: Failed", 3, ok and 0 or 255, ok and 255 or 0, 0)
        end
    elseif not silent then
        ding("<b>Copy</b>: Clipboard unavailable", 3, 255, 255, 0)
    end
end

function loc.PasteDirect()
    if getclipboard then
        local text = getclipboard()
        if type(text) == "string" then
            code.Text = text
            ding("<b>Paste</b>: Success", 3, 0, 255, 0)
            return
        end
    end
    ding("<b>Paste</b>: Clipboard unavailable", 3, 255, 255, 0)
end

function loc.ClearDirect()
    code.Text = ""
    ding("<b>Clear</b>: Cleared", 2.5, 0, 255, 255)
end

function loc.SyncStorage()
    loc.LoadDraft()
    loc.SyncSeen = {}
    loc.SyncFiles = {}

    for _, path in ipairs(listfiles(loc.TabsRoot)) do
        if path:lower():match("%.lua$") then
            local text = readfile(path)
            local id = loc.ReadScriptID(text)

            if not loc.ValidScriptID(id) or loc.SyncSeen[id] then
                id = loc.NewScriptID()
                text = loc.WithScriptID(loc.StripScriptID(text), id)
                writefile(path, text)
            end

            loc.SyncSeen[id] = true
            loc.SyncFiles[id] = path
            local meta = loc.FindMeta(id)
            local filename = path:match("([^/\\]+)$") or "Script.lua"

            if not meta then
                table.insert(loc.Draft.Scripts, {
                    ScriptID = id,
                    Title = filename,
                    IsTextEditable = true,
                    BackgroundColor3 = loc.DefaultBackgroundColor3,
                    TextColor3 = loc.DefaultTextColor3
                })
            else
                meta.Title = tostring(meta.Title or filename)
                meta.IsTextEditable = meta.IsTextEditable ~= false
                meta.BackgroundColor3 = tostring(meta.BackgroundColor3 or loc.DefaultBackgroundColor3)
                meta.TextColor3 = tostring(meta.TextColor3 or loc.DefaultTextColor3)
            end
        end
    end

    for i = #loc.Draft.Scripts, 1, -1 do
        if not loc.SyncFiles[loc.Draft.Scripts[i].ScriptID] then
            table.remove(loc.Draft.Scripts, i)
        end
    end
    loc.SaveDraft()
end

local function btnb(name, image, scriptFn, callback)
  local btn = Instance.new("ImageButton")
  btn.Name = tostring(name)
  btn.BackgroundColor3 = Color3.fromRGB(88,88,88)
  btn.Size = UDim2.new(0,35,0,35)
  btn.Image = "rbxassetid://".. tonumber(image)
  btn.Parent = e_ba
  Corner(1,0,btn)

  btn.MouseButton1Click:Connect(function()
    if scriptFn then
      scriptFn()
      return
    end
    if callback then
      callback()
      return
    end
    if name == "Execute" then
      loc.RunDirect()
    elseif name == "Debug" then
      loc.DebugDirect()
    elseif name == "Copy" then
      loc.CopyDirect()
    elseif name == "Paste" then
      loc.PasteDirect()
    elseif name == "Clear" then
      loc.ClearDirect()
    end
  end)
end

btnb("Execute", "118198625280331") -- Execute from tab (codd) or file
btnb("Debug", "81804636064090") -- Debug wuthout execute
btnb("Copy", "73808285755928") -- Copy from code or file
btnb("Paste", "76818256740269") -- Paste into code
btnb("Clear", "117574526695486") -- Clear code

local function tog(
    hastxt, ntxt,
    hasbtn, nbtn,
    hasbox, nbox,
    scriptFn, callback, state)
  
    hastxt = hastxt == true
    hasbtn = hasbtn == true
    hasbox = hasbox == true

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 0, 30)
    body.BackgroundColor3 = Color3.fromRGB(88, 88, 88)
    body.BorderMode = Enum.BorderMode.Inset
    body.BorderSizePixel = 5
    body.Active = false
    body.ZIndex = 1
    body.Parent = e_mo2
    Corner(0, 8, body)

    local elements = {}
    local count = 0

    local function register(obj, enabled)
        obj.Visible = enabled
        obj.Parent = body

        if enabled then
            count += 1
            elements[#elements + 1] = obj
        end
    end

    local txt = Instance.new("TextLabel")
    txt.Name = tostring(ntxt or "Label")
    txt.BackgroundTransparency = 1
    txt.BorderMode = Enum.BorderMode.Inset
    txt.TextScaled = true
    txt.RichText = true
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Text = tostring(ntxt or "Unknown function")
    txt.TextXAlignment = Enum.TextXAlignment.Left
    register(txt, hastxt)

    local box = Instance.new("TextBox")
    box.Name = tostring(nbox or "Input")
    box.BackgroundTransparency = 0.5
    box.TextScaled = true
    box.RichText = true
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BorderMode = Enum.BorderMode.Inset
    box.BorderSizePixel = 2
    box.Text = ""
    box.PlaceholderColor3 = Color3.new(1,1,1)
    box.PlaceholderText = tostring(nbox or "Enter value")
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    register(box, hasbox)
    Corner(0, 8, box)

    local btn = Instance.new("TextButton")
    btn.Name = tostring(nbtn or "Button")
    btn.BackgroundTransparency = 0.3
    btn.TextScaled = true
    btn.RichText = true
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderMode = Enum.BorderMode.Inset
    btn.BorderSizePixel = 2
    btn.Text = tostring(nbtn or "OK")
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Active = true
    btn.Selectable = true
    btn.AutoButtonColor = true
    btn.ZIndex = 1
    register(btn, hasbtn)
    Corner(0, 8, btn)

    -- Calculate the layout of visible elements only.
    if count > 0 then
        local width = 1 / count

        for index, obj in ipairs(elements) do
            obj.Size = UDim2.new(width, 0, 1, 0)
            obj.Position = UDim2.new((index - 1) * width, 0, 0, 0)
        end
    end

    -- Initial toggle state: state must be boolean to enable toggle mode.
    local toggleState = type(state) == "boolean" and state or nil

    local function activate(source)
        if source == "Button" and toggleState ~= nil then
            toggleState = not toggleState
            btn.Text = toggleState and "ON" or "OFF"

            if callback then
                callback(toggleState, box, btn)
            end
        elseif scriptFn then
            scriptFn(box, btn, toggleState)
        end
    end

    if hasbtn then
        if toggleState ~= nil then
            btn.Text = toggleState and "ON" or "OFF"
        end

        btn.MouseButton1Click:Connect(function()
            activate("Button")
        end)
    end

    if hasbox then
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                activate("TextBox")
            end
        end)
    end

    return {
        Frame = body,
        Label = txt,
        Box = box,
        Button = btn,

        GetState = function()
            return toggleState
        end,

        SetState = function(value)
            if type(value) == "boolean" then
                toggleState = value

                if hasbtn then
                    btn.Text = toggleState and "ON" or "OFF"
                end
            end
        end
    }
end

--[[
    hastxt, ntxt,
    hasbtn, nbtn,
    hasbox, nbox,
    scriptFn, callback, state
]]

loc.HideBarUI = tog(true, "Hide Bar", true, "Visible", nil,nil,
    function(_, btn)
        loc.hide_e_ba = not loc.hide_e_ba
        e_ba.Visible = not loc.hide_e_ba
        btn.Text = loc.hide_e_ba and "Hidden" or "Visible"
        ding("<b>Hide Bar</b>: " .. (loc.hide_e_ba and "Hidden" or "Visible"), 2.5, 0,255,255)
    end)

e_ba.Visible = not loc.hide_e_ba

loc.DirectUI = tog(true, "Select Directly at", true, "Tab", nil,nil,
    function(_, btn)
        loc.DirectTarget = loc.DirectTarget == "Tab" and "File" or "Tab"
        btn.Text = loc.DirectTarget
        ding("<b>Direct Target</b>: " .. loc.DirectTarget, 2.5, 0,255,255)
    end) -- Tab / File and connect to btnb

loc.TextSizeUI = tog(true, "TextSize", nil,nil, true, "14", function(box)
    local value = tonumber(box.Text)
    if not value then
        box.Text = tostring(code.TextSize)
        ding("<b>TextSize</b>: Invalid value", 2.5, 255, 255, 0)
        return
    end
    value = math.clamp(math.floor(value), 1, 200)
    syn.TextSize = value
    code.TextSize = value
    linen.TextSize = value
    box.Text = tostring(value)
    task.defer(loc.UpdateLineNumbers)
    ding("<b>TextSize</b>: " .. tostring(value), 2.5, 0,255,255)
end)
loc.TextSizeUI.Box.Text = tostring(code.TextSize)

loc.SyntaxMode = "Edit Only"
loc.SyntaxEnabled = true

loc.SyntaxUI = tog(true, "Syntax highlights", true, "Edit Only", nil, nil, nil, function(_, _, btn)
    if loc.SyntaxMode == "OFF" then
        loc.SyntaxMode = "ON"
    elseif loc.SyntaxMode == "ON" then
        loc.SyntaxMode = "Edit Only"
    else
        loc.SyntaxMode = "OFF"
    end

    loc.SyntaxEnabled = loc.SyntaxMode ~= "OFF"
    btn.Text = loc.SyntaxMode
    loc.ApplySyntaxMode()
    loc.UpdateSyntax()
end, true)

loc.SyntaxUI.Button.Text = "Edit Only"
loc.ApplySyntaxMode()
loc.UpdateSyntax()

-- tog(true, "Syntax Preview", true, "OFF", nil,nil) did NOT exist lmfao
loc.ConsoleUI = tog(true, "LogService - Console", true, "ON", nil,nil, nil, function(state, _, btn)
    e_cs.Visible = state
    btn.Text = state and "ON" or "OFF"
    ding("<b>Console</b>: " .. (state and "Visible" or "Hidden"), 2.5, 0,255,255)
end, true) -- Visible true / false

loc.ClearConsoleUI = tog(true, "Clear Console", true, "Clear", nil,nil, function()
    loc.OutputQueue = {}
    loc.NextOutputOrder = 0
    for i = #loc.ConList, 1, -1 do
        if loc.ConList[i] and loc.ConList[i].Parent then loc.ConList[i]:Destroy() end
        loc.ConList[i] = nil
    end
    ding("<b>Clear Console</b>: Cleared", 2.5, 0,255,255)
end) -- Clear all TextButton

loc.ConsoleLimitUI = tog(true, "Console Limit", true, "Set", true, "250", function(box)
    local value = tonumber(box.Text)
    if not value then
        box.Text = tostring(loc.MaxOutputs)
        ding("<b>Console Limit</b>: Invalid value", 2.5, 255, 255, 0)
        return
    end
    value = math.clamp(math.floor(value), 1, 1000)
    loc.MaxOutputs = value
    box.Text = tostring(value)
    while #loc.ConList > loc.MaxOutputs do table.remove(loc.ConList):Destroy() end
    ding("<b>Console Limit</b>: " .. tostring(value), 2.5, 0,255,255)
end)
loc.ConsoleLimitUI.Box.Text = tostring(loc.MaxOutputs)

loc.SaveUI = tog(true, "Save", true, "Save", true, "Script.lua", function(box, btn)
    if loc.SaveNew then loc.SaveNew(box, btn) end
end) -- Will not be available if already select tab
loc.SaveAsUI = tog(true, "Save as", true, "Save", true, "Put tab name", function(box, btn)
    if loc.SaveAs then loc.SaveAs(box, btn) end
end) -- Will not be available if did not select tab first
loc.UpdateSaveRows()


local e_mo = Instance.new("TextButton")
e_mo.Name = "EditorMore"
e_mo.Size = UDim2.new(0,40,0,40)
e_mo.Position = UDim2.new(1,-50,1,-50)
e_mo.BorderMode = Enum.BorderMode.Inset
e_mo.BorderSizePixel = 5
e_mo.BackgroundColor3 = Color3.fromRGB(255,255,255)
e_mo.BackgroundTransparency = 0.3
e_mo.TextSize = 10
e_mo.TextColor3 = Color3.new(0,0,0)
e_mo.ZIndex = 1
e_mo.Text = "•••"
e_mo.Parent = e_ed
Corner(1,0,e_mo)

e_mo2.Size = UDim2.new(0, 245, 0, 205)
e_mo2.Visible = false
e_mo.Text = "•••"

local moOpen = false
local moBusy = false

e_mo.MouseButton1Click:Connect(function()
    if moBusy then return end
    moBusy = true

    if moOpen then
        -- Close
        moOpen = false
        e_mo.Text = "•••"

        local tween = s.TweenService:Create(
    e_mo2,
    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {Size = UDim2.new(0, 245, 0, 0)}
)

        tween:Play()
        tween.Completed:Wait()
        e_mo2.Visible = false
    else
        -- Open
        moOpen = true
        e_mo.Text = "X"
        e_mo2.Visible = true
        e_mo2.Size = UDim2.new(0, 245, 0, 0)

        local tween = s.TweenService:Create(
    e_mo2,
    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 245, 1, -60)}
)

        tween:Play()
        tween.Completed:Wait()
    end

    moBusy = false
end)

e_cs = Instance.new("ScrollingFrame")
e_cs.Name = "Console"
e_cs.Size = UDim2.new(0.8,-5,0.2,0)
e_cs.Position = UDim2.new(0.2,5,0.8,0)
e_cs.BorderMode = Enum.BorderMode.Inset
e_cs.BorderSizePixel = 5
e_cs.BackgroundColor3 = Color3.fromRGB(0,0,0)
e_cs.CanvasSize = UDim2.new(0,0,0,0)
e_cs.ScrollBarThickness = 0
e_cs.ScrollingDirection = Enum.ScrollingDirection.Y
e_cs.AutomaticCanvasSize = Enum.AutomaticSize.Y
e_cs.Parent = ic2.Editor
Corner(0,8,e_cs)
ListLayout(e_cs,0,3,"HLeft","VTop","SLayout","FillV")

loc.ConList = {}
loc.OutputQueue = {}
loc.ConsoleProcessing = false
loc.NextOutputOrder = 0

loc.OutputColors = {
    [Enum.MessageType.MessageOutput] = Color3.fromRGB(255, 255, 255),
    [Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 255, 0),
    [Enum.MessageType.MessageError] = Color3.fromRGB(255, 0, 0),
    [Enum.MessageType.MessageInfo] = Color3.fromRGB(0, 255, 255)
}

local function con(output, messageType)
    table.insert(loc.OutputQueue, {
        Text = tostring(output),
        Type = messageType
    })

    if loc.ConsoleProcessing then
        return
    end

    loc.ConsoleProcessing = true

    task.spawn(function()
        while #loc.OutputQueue > 0 do
            local item = table.remove(loc.OutputQueue, 1)
            local color = loc.OutputColors[item.Type]
                or Color3.fromRGB(255, 255, 255)

            local btn = Instance.new("TextButton")
            btn.Name = "Output"
            btn.AutomaticSize = Enum.AutomaticSize.Y
            btn.Size = UDim2.new(1, 0, 0, 0)
            btn.BackgroundTransparency = 0.6
            btn.BackgroundColor3 = color
            btn.TextColor3 = color
            btn.Text = item.Text
            btn.TextWrapped = true
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextYAlignment = Enum.TextYAlignment.Top
            btn.BorderMode = Enum.BorderMode.Inset
            btn.BorderSizePixel = 3
            loc.NextOutputOrder = tonumber(loc.NextOutputOrder) or 0
            btn.LayoutOrder = loc.NextOutputOrder
            loc.NextOutputOrder = loc.NextOutputOrder - 1
            btn.Parent = e_cs

            Corner(0, 3, btn)

            local lastClick = 0

btn.MouseButton1Click:Connect(function()
    local now = os.clock()

    if now - lastClick <= 0.4 then
        lastClick = 0

        if setclipboard then
            local ok=pcall(setclipboard, btn.Text)
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            ding(ok and "<b>Console</b>: Copied" or "<b>Console</b>: Copy failed", 2.5, ok and 0 or 255, ok and 255 or 0, 0)

            task.delay(0.3, function()
                if btn and btn.Parent then
                    btn.TextColor3 = color
                end
            end)
        else
            ding("<b>Console</b>: Clipboard unavailable", 2.5, 255, 255, 0)
        end
    else
        lastClick = now
    end
end)

            table.insert(loc.ConList, 1, btn)

            if #loc.ConList > loc.MaxOutputs then
                table.remove(loc.ConList):Destroy()
            end

            task.wait(0.03)
        end

        loc.ConsoleProcessing = false
    end)
end

s.LogService.MessageOut:Connect(function(message, messageType)
    con(message, messageType)
end)

-- Just testing
con("Hello, World!", Enum.MessageType.MessageOutput)
con("Not done yet, keep waiting for the update.", Enum.MessageType.MessageWarning)

local e_sc = Instance.new("ScrollingFrame")
e_sc.Name = "Tabs"
e_sc.Size = UDim2.new(0.2,0,1,0)
e_sc.BorderMode = Enum.BorderMode.Inset
e_sc.BorderSizePixel = 5
e_sc.BackgroundColor3 = Color3.fromRGB(37,37,37)
e_sc.CanvasSize = UDim2.new(0,0,0,0)
e_sc.ScrollBarThickness = 0
e_sc.ScrollingDirection = Enum.ScrollingDirection.Y
e_sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
e_sc.Parent = ic2.Editor
Corner(0,8,e_sc)
ListLayout(e_sc,0,3,"HCenter","VTop","SLayout","FillV")

local selectTab = {}

local function addtab(file, autoSelect)
    local path = file and tostring(file) or nil
    local id = nil
    local text = ""
    local meta

    if path and not path:find("/") then path = loc.TabsRoot .. "/" .. path end

    if not path then
        -- Reopen an existing file that is not already represented by a tab.
        for _, existingPath in ipairs(listfiles(loc.TabsRoot)) do
            if existingPath:lower():match("%.lua$") then
                local alreadyOpen = false
                for _, openTab in ipairs(selectTab) do
                    local openPath = openTab:GetAttribute("FilePath")
                    if openPath and tostring(openPath):lower() == tostring(existingPath):lower() then
                        alreadyOpen = true
                        break
                    end
                end
                if not alreadyOpen then
                    path = existingPath
                    break
                end
            end
        end

        -- No recoverable file: create a new one.
        if not path then
            id = loc.NewScriptID()
            local base = "Script.lua"
            path = loc.TabsRoot .. "/" .. base
            if isfile(path) then
                local n = 1
                while isfile(loc.TabsRoot .. "/Script_" .. n .. ".lua") do n += 1 end
                path = loc.TabsRoot .. "/Script_" .. n .. ".lua"
            end
            writefile(path, loc.WithScriptID("", id))
        end
    end

    if not isfile(path) then return end
    text = readfile(path)
    id = loc.ReadScriptID(text)
    if not loc.ValidScriptID(id) then
        id = loc.NewScriptID()
        text = loc.WithScriptID(loc.StripScriptID(text), id)
        writefile(path, text)
    end

    meta = loc.FindMeta(id)
    if not meta then
        meta = {
            ScriptID = id,
            Title = path:match("([^/\\]+)$") or "Script.lua",
            IsTextEditable = true,
            BackgroundColor3 = loc.DefaultBackgroundColor3,
            TextColor3 = loc.DefaultTextColor3
        }
        table.insert(loc.Draft.Scripts, meta)
        loc.SaveDraft()
    end

    local btn = Instance.new("TextButton")
    btn.Name = tostring(meta.Title)
    btn.Size = UDim2.new(1,0,0,35)
    btn.BorderMode = Enum.BorderMode.Inset
    btn.BorderSizePixel = 5
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutomaticSize = Enum.AutomaticSize.Y
    btn.TextColor3 = loc.ParseRGB(meta.TextColor3, Color3.fromRGB(255,255,255))
    btn.BackgroundColor3 = loc.ParseRGB(meta.BackgroundColor3, Color3.fromRGB(79,79,79))
    btn.Text = ""
    btn.Parent = e_sc
    btn:SetAttribute("FilePath", path)
    btn:SetAttribute("ScriptID", id)
    Corner(0,5,btn)

    local options = Instance.new("ScrollingFrame")
    options.Name = "Options"
    options.Size = UDim2.new(1,0,0,0)
    options.Position = UDim2.new(0,0,0,30)
    options.BackgroundColor3 = Color3.fromRGB(131,131,131)
    options.Visible = false
    options.BorderMode = Enum.BorderMode.Inset
    options.BorderSizePixel = 5
    options.CanvasSize = UDim2.new(0,0,0,0)
    options.AutomaticCanvasSize = Enum.AutomaticSize.Y
    options.ScrollingDirection = Enum.ScrollingDirection.Y
    options.ScrollBarThickness = 0
    options.Parent = btn
    Corner(0,5,options)
    ListLayout(options,0,3,"HLeft","VTop","SLayout","FillV")

    local more = Instance.new("TextButton")
    more.Name = "more"
    more.Size = UDim2.new(0,25,0,25)
    more.Position = UDim2.new(1,-25,0,0)
    more.BackgroundColor3 = Color3.fromRGB(121,121,121)
    more.BorderMode = Enum.BorderMode.Inset
    more.BorderSizePixel = 3
    more.TextScaled = true
    more.TextColor3 = Color3.new(1,1,1)
    more.Text = "•••"
    more.Parent = btn
    Corner(0,3,more)

    local del = Instance.new("TextButton"); del.Name="Delete"; del.Size=UDim2.new(1,0,0,25); del.BackgroundColor3=Color3.fromRGB(63,0,0); del.BorderMode=Enum.BorderMode.Inset; del.BorderSizePixel=3; del.TextScaled=true; del.TextColor3=Color3.new(1,0,0); del.Text="Delete"; del.Parent=options; Corner(0,3,del)
    local dup = Instance.new("TextButton"); dup.Name="Duplicate"; dup.Size=UDim2.new(1,0,0,25); dup.BackgroundColor3=Color3.fromRGB(170,255,255); dup.BorderMode=Enum.BorderMode.Inset; dup.BorderSizePixel=3; dup.TextScaled=true; dup.TextColor3=Color3.fromRGB(0,85,255); dup.Text="Duplicate"; dup.Parent=options; Corner(0,3,dup)
    local exe = Instance.new("TextButton"); exe.Name="Execute"; exe.Size=UDim2.new(1,0,0,25); exe.BackgroundColor3=Color3.fromRGB(85,255,127); exe.BorderMode=Enum.BorderMode.Inset; exe.BorderSizePixel=3; exe.TextScaled=true; exe.TextColor3=Color3.fromRGB(0,170,0); exe.Text="Execute"; exe.Parent=options; Corner(0,3,exe)
    local cop = Instance.new("TextButton"); cop.Name="Copy"; cop.Size=UDim2.new(1,0,0,25); cop.BackgroundColor3=Color3.fromRGB(255,255,127); cop.BorderMode=Enum.BorderMode.Inset; cop.BorderSizePixel=3; cop.TextScaled=true; cop.TextColor3=Color3.fromRGB(255,170,0); cop.Text="Copy"; cop.Parent=options; Corner(0,3,cop)
    local lock = Instance.new("TextButton"); lock.Name="LockEditable"; lock.Size=UDim2.new(1,0,0,25); lock.BackgroundColor3=Color3.fromRGB(0,0,0); lock.BorderMode=Enum.BorderMode.Inset; lock.BorderSizePixel=3; lock.TextScaled=true; lock.Parent=options; Corner(0,3,lock)

    local bac = Instance.new("TextBox"); bac.Name="BackgroundColor3"; bac.Size=UDim2.new(1,0,0,25); bac.BackgroundColor3=Color3.fromRGB(0,0,0); bac.BackgroundTransparency=0.8; bac.BorderMode=Enum.BorderMode.Inset; bac.BorderSizePixel=3; bac.TextScaled=true; bac.TextColor3=loc.ParseRGB(meta.BackgroundColor3,Color3.fromRGB(79,79,79)); bac.Text=tostring(meta.BackgroundColor3); bac.PlaceholderText="BackgroundColor3: 79,79,79"; bac.ClearTextOnFocus=true; bac.Parent=options; Corner(0,3,bac)
    local tc3 = Instance.new("TextBox"); tc3.Name="TextColor3"; tc3.Size=UDim2.new(1,0,0,25); tc3.BackgroundColor3=Color3.fromRGB(0,0,0); tc3.BackgroundTransparency=0.8; tc3.BorderMode=Enum.BorderMode.Inset; tc3.BorderSizePixel=3; tc3.TextScaled=true; tc3.TextColor3=loc.ParseRGB(meta.TextColor3,Color3.fromRGB(255,255,255)); tc3.Text=tostring(meta.TextColor3); tc3.PlaceholderText="TextColor3: 255,255,255"; tc3.ClearTextOnFocus=true; tc3.Parent=options; Corner(0,3,tc3)
    local sid = Instance.new("TextLabel"); sid.Name="ScriptID"; sid.Size=UDim2.new(1,0,0,25); sid.BackgroundColor3=Color3.fromRGB(255,255,255); sid.BorderMode=Enum.BorderMode.Inset; sid.BorderSizePixel=3; sid.TextScaled=true; sid.TextColor3=Color3.new(0,0,0); sid.Text="ScriptID: "..id; sid.Parent=options; Corner(0,3,sid)
    local title = Instance.new("TextBox"); title.Name="Title"; title.Size=UDim2.new(1,-28,0,25); title.BorderMode=Enum.BorderMode.Inset; title.BorderSizePixel=3; title.BackgroundTransparency=1; title.Active=false; title.TextEditable=false; title.ClearTextOnFocus=false; title.TextColor3=loc.ParseRGB(meta.TextColor3,Color3.fromRGB(255,255,255)); title.TextScaled=true; title.TextSize=24; title.TextXAlignment=Enum.TextXAlignment.Left; title.Text=tostring(meta.Title); title.PlaceholderText="Script.lua"; title.PlaceholderColor3=Color3.new(1,1,1); title.Parent=btn

    table.insert(selectTab, btn)

    more.MouseButton1Click:Connect(function()
        if options.Visible then
            more.Text="•••"; more.TextColor3=Color3.new(1,1,1); Tween(options,UDim2.new(1,0,0,0),nil,nil,nil,0.2); Tween(more,nil,nil,Color3.fromRGB(121,121,121),nil,0.2).Completed:Wait(); options.Visible=false
        else
            more.Text="X"; more.TextColor3=Color3.new(1,1,1); options.Visible=true; Tween(options,UDim2.new(1,0,0,150),nil,nil,nil,0.2)
        end
    end)

    local function selectCurrent()
        for _, otherbtn in ipairs(selectTab) do
            Tween(otherbtn,nil,nil,Color3.fromRGB(79,79,79),nil,0.2)
            local otherTitle=otherbtn:FindFirstChild("Title")
            if otherbtn~=btn and otherTitle and otherTitle.TextEditable then otherTitle.TextEditable=false; otherTitle.Active=false end
        end
        Tween(btn,nil,nil,Color3.fromRGB(150,150,150),nil,0.2)
        loc.SelectedTab=btn
        loc.AutoSaveLoading = true
        code.Text=loc.StripScriptID(readfile(path))
        loc.AutoSaveLoading = false
        code.TextEditable=meta.IsTextEditable~=false
        code.TextColor3=loc.ParseRGB(meta.TextColor3,Color3.fromRGB(255,255,255))
        linen.TextColor3=code.TextColor3
        bac.Text=tostring(meta.BackgroundColor3)
        tc3.Text=tostring(meta.TextColor3)
        sid.Text="ScriptID: "..tostring(meta.ScriptID)
        if loc.SaveAsUI and loc.SaveAsUI.Box then
            loc.SaveAsUI.Box.Text = tostring(meta.Title)
        end
        lock.Text=code.TextEditable and "Lock Editable" or "Unlock Editable"
        lock.TextColor3=code.TextEditable and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        loc.UpdateSaveRows(); task.defer(loc.UpdateLineNumbers)
        ding("<b>Select</b>: " .. tostring(meta.Title) .. " | ScriptID: " .. tostring(meta.ScriptID), 2.5, 0,255,255)
    end

    btn.MouseButton1Click:Connect(selectCurrent)

    local lastClick=0; local originalTitle=title.Text; local editing=false
    title.InputBegan:Connect(function(input)
        if editing then return end
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        local now=os.clock()
        if now-lastClick<=1 then lastClick=0; originalTitle=title.Text; editing=true; title.TextEditable=true; title.Active=true; title:CaptureFocus() else lastClick=now end
    end)
    title.FocusLost:Connect(function()
        if not editing then return end
        if title.Text:match("^%s*$") then title.Text="Script.lua" end
        editing=false; title.TextEditable=false; title.Active=false
        meta.Title=title.Text; btn.Name=title.Text; loc.SaveDraft()
    end)

    loc.EscapeConnections=loc.EscapeConnections or {}
    table.insert(loc.EscapeConnections,s.UserInputService.InputBegan:Connect(function(input)
        if editing and input.KeyCode==Enum.KeyCode.Escape then title.Text=originalTitle; title.TextEditable=false; title.Active=false; editing=false end
    end))

    lock.Text=meta.IsTextEditable~=false and "Lock Editable" or "Unlock Editable"
    lock.TextColor3=meta.IsTextEditable~=false and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    lock.MouseButton1Click:Connect(function()
        meta.IsTextEditable=not(meta.IsTextEditable~=false); code.TextEditable=meta.IsTextEditable; lock.Text=meta.IsTextEditable and "Lock Editable" or "Unlock Editable"; lock.TextColor3=meta.IsTextEditable and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0); loc.SaveDraft()
    end)
    bac.FocusLost:Connect(function()
        if loc.ParseRGB(bac.Text,nil) then meta.BackgroundColor3=bac.Text:gsub("%s+",""); btn.BackgroundColor3=loc.ParseRGB(meta.BackgroundColor3,btn.BackgroundColor3); loc.SaveDraft() else bac.Text=meta.BackgroundColor3 end
    end)
    tc3.FocusLost:Connect(function()
        if loc.ParseRGB(tc3.Text,nil) then meta.TextColor3=tc3.Text:gsub("%s+",""); btn.TextColor3=loc.ParseRGB(meta.TextColor3,btn.TextColor3); title.TextColor3=btn.TextColor3; if loc.SelectedTab==btn then code.TextColor3=btn.TextColor3; linen.TextColor3=btn.TextColor3 end; loc.SaveDraft() else tc3.Text=meta.TextColor3 end
    end)
    exe.MouseButton1Click:Connect(function()
        loc.SelectedTab=btn; loc.DirectTarget="File"; loc.RunDirect(true)
    end)
    cop.MouseButton1Click:Connect(function()
        loc.SelectedTab=btn; loc.DirectTarget="File"; loc.CopyDirect(true)
    end)
    dup.MouseButton1Click:Connect(function()
        local source=loc.StripScriptID(readfile(path)); local newID=loc.NewScriptID(); local newName=loc.SafeFileName(title.Text:gsub("%.lua$","").."_Copy.lua"); local newPath=loc.TabsRoot.."/"..newName
        if isfile(newPath) then newName=loc.SafeFileName(title.Text:gsub("%.lua$","").."_Copy_"..newID:sub(1,6)..".lua"); newPath=loc.TabsRoot.."/"..newName end
        writefile(newPath,loc.WithScriptID(source,newID)); table.insert(loc.Draft.Scripts,{ScriptID=newID,Title=newName,IsTextEditable=meta.IsTextEditable~=false,BackgroundColor3=tostring(meta.BackgroundColor3),TextColor3=tostring(meta.TextColor3)}); loc.SaveDraft(); addtab(newPath)
    end)
    del.MouseButton1Click:Connect(function()
        if path and isfile(path) then delfile(path) end; loc.RemoveMeta(id); if loc.SelectedTab==btn then loc.SelectedTab=nil; code.Text=""; code.TextEditable=true end; for i,tab in ipairs(selectTab) do if tab==btn then table.remove(selectTab,i); break end end; loc.SaveDraft(); btn:Destroy(); loc.UpdateSaveRows()
    end)
    if autoSelect then
        selectCurrent()
    end

    return btn
end

loc.SaveNew=function(box,btn)
    if loc.SelectedTab then
        ding("<b>Save</b>: No tab/file selected", 3, 255,255,0)
        return
    end
    local name=loc.SafeFileName(box.Text); local path=loc.TabsRoot.."/"..name
    if isfile(path) then
        ding("<b>Save</b>: File already exists | "..name,3,255,255,0)
        return
    end
    local id=loc.NewScriptID()
    local ok=pcall(writefile,path,loc.WithScriptID(code.Text,id))
    if not ok then
        ding("<b>Save</b>: Failed | "..name.." | ScriptID: "..id,3,255,0,0)
        return
    end
    table.insert(loc.Draft.Scripts,{ScriptID=id,Title=name,IsTextEditable=code.TextEditable~=false,BackgroundColor3=loc.DefaultBackgroundColor3,TextColor3=loc.DefaultTextColor3})
    loc.SaveDraft(); box.Text=name
    addtab(path, true)
    ding("<b>Save</b>: "..name.." | ScriptID: "..id,3,0,255,0)
end

loc.SaveAs=function(box,btn)
    if not loc.SelectedTab then
        ding("<b>Save as</b>: Select a tab/file first", 3, 255,255,0)
        return
    end
    local old=loc.SelectedTab; local oldPath=old:GetAttribute("FilePath"); local oldID=old:GetAttribute("ScriptID")
    if not oldPath or oldPath=="" or not oldID then
        ding("<b>Save as</b>: Selected file is invalid", 3, 255,0,0)
        return
    end

    local typed=tostring(box.Text or "")
    local currentName=tostring(old:GetAttribute("FilePath") or ""):match("([^/\\]+)$") or "Script.lua"
    local name=typed:gsub("^%s+",""):gsub("%s+$","")
    if name=="" then name=currentName end
    name=loc.SafeFileName(name)

    local path=loc.TabsRoot.."/"..name
    local targetID=oldID

    -- Same selected file: overwrite it in place and keep its ScriptID.
    if path==oldPath then
        targetID=oldID
    elseif isfile(path) then
        targetID=loc.ReadScriptID(readfile(path))
        if not loc.ValidScriptID(targetID) then targetID=loc.NewScriptID() end
    end

    local ok=pcall(writefile,path,loc.WithScriptID(code.Text,targetID))
    if not ok then
        ding("<b>Save as</b>: Failed | "..name.." | ScriptID: "..tostring(targetID),3,255,0,0)
        return
    end

    if path~=oldPath and isfile(oldPath) then delfile(oldPath); loc.RemoveMeta(oldID) end
    local meta=loc.FindMeta(targetID)
    if not meta then meta={ScriptID=targetID,Title=name,IsTextEditable=code.TextEditable~=false,BackgroundColor3=loc.DefaultBackgroundColor3,TextColor3=loc.DefaultTextColor3}; table.insert(loc.Draft.Scripts,meta) end
    meta.Title=name; meta.IsTextEditable=code.TextEditable~=false; loc.SaveDraft()

    old:SetAttribute("FilePath",path); old:SetAttribute("ScriptID",targetID); old.Name=name
    local title=old:FindFirstChild("Title"); local options=old:FindFirstChild("Options"); local sid=options and options:FindFirstChild("ScriptID"); if title then title.Text=name end; if sid then sid.Text="ScriptID: "..targetID end
    box.Text=name; loc.UpdateSaveRows(); ding("<b>Save as</b>: "..name.." | ScriptID: "..tostring(targetID),3,0,255,0)
end


local add = Instance.new("TextButton")
add.Name = "add"
add.Size = UDim2.new(0,35,0,35)
add.BorderMode = Enum.BorderMode.Inset
add.BorderSizePixel = 5
add.TextXAlignment = Enum.TextXAlignment.Center
add.AutomaticSize = Enum.AutomaticSize.None
add.TextColor3 = Color3.new(1,1,1)
add.BackgroundColor3 = Color3.fromRGB(79,79,79)
add.TextScaled = true
add.Text = "+"
add.LayoutOrder = 2147483647
add.Parent = e_sc
Corner(0,5,add)

-- Load every existing .lua file from the editor folder into the tab UI.
-- Existing ScriptID values are kept; addtab only creates a new ID for a file
-- that does not have a valid ScriptID yet.
loc.SyncStorage()

local startupFiles = {}
for _, existingPath in ipairs(listfiles(loc.TabsRoot)) do
    if existingPath:lower():match("%.lua$") then
        table.insert(startupFiles, existingPath)
    end
end

table.sort(startupFiles, function(a, b)
    return tostring(a):lower() < tostring(b):lower()
end)

for i, existingPath in ipairs(startupFiles) do
    addtab(existingPath, i == 1)
end

add.MouseButton1Click:Connect(function()
    local added=addtab(nil, true)
    if added then
        ding("<b>Add Tab</b>: " .. tostring(added:GetAttribute("ScriptID") or "Created"), 2.5, 0,255,255)
    else
        ding("<b>Add Tab</b>: Failed", 2.5, 255,0,0)
    end
end)

task.defer(loc.UpdateLineNumbers)

ding("Hello, World!", 5, 0,255,255)
task.wait(1)
ding("Load successful", 5, 0,255,0)
task.wait(1)
ding([[ExperienceSettings (Beta); Notification from <b>Editor</b> &lt;3
  ———————————————————————————
  Version ExperienceSettings: <b>0.821.1.4-Beta</b>
  Version Editor: <b>]].. v_ver .."</b>", 8, 255,255,0)
