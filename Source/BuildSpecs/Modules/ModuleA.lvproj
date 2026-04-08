<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="23008000">
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">true</Property>
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="ModuleA.lvlib" Type="Library" URL="../../../Modules/ModuleA/ModuleA.lvlib"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="ABComm.lvlib" Type="Library" URL="../../../Communication/ABComm/ABComm.lvlib"/>
			<Item Name="ACComm.lvlib" Type="Library" URL="../../../Communication/ACComm/ACComm.lvlib"/>
			<Item Name="FileUtilities.lvlib" Type="Library" URL="../../../Utilities/FileUtilities/FileUtilities.lvlib"/>
			<Item Name="ModuleB.lvlib" Type="Library" URL="../../../Modules/ModuleB/ModuleB.lvlib"/>
			<Item Name="StringUtilities.lvlib" Type="Library" URL="../../../Utilities/StringUtilities/StringUtilities.lvlib"/>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="ModuleA" Type="Packed Library">
				<Property Name="Bld_autoIncrement" Type="Bool">true</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{6F89D119-A8F4-4EA0-89D9-22FD2F0B310B}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">ModuleA</Property>
				<Property Name="Bld_excludeDependentDLLs" Type="Bool">true</Property>
				<Property Name="Bld_excludeDependentPPLs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/PackedLibraries</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{383F399E-6686-41FC-9917-48851BBEAD23}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">ModuleA.lvlibp</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/PackedLibraries/NI_AB_PROJECTNAME.lvlibp</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/PackedLibraries</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="PackedLib_callersAdapt" Type="Bool">true</Property>
				<Property Name="Source[0].itemID" Type="Str">{8C51EBD4-B1A9-48E0-AF0F-030358BD3C62}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/ModuleA.lvlib</Property>
				<Property Name="Source[1].Library.allowMissingMembers" Type="Bool">true</Property>
				<Property Name="Source[1].Library.atomicCopy" Type="Bool">true</Property>
				<Property Name="Source[1].Library.LVLIBPtopLevel" Type="Bool">true</Property>
				<Property Name="Source[1].preventRename" Type="Bool">true</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">Library</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_companyName" Type="Str">None</Property>
				<Property Name="TgtF_fileDescription" Type="Str">ModuleA</Property>
				<Property Name="TgtF_internalName" Type="Str">ModuleA</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2026 None</Property>
				<Property Name="TgtF_productName" Type="Str">ModuleA</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{858243B1-92E2-4F6F-9258-DC51B5C7342D}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">ModuleA.lvlibp</Property>
				<Property Name="TgtF_versionIndependent" Type="Bool">true</Property>
			</Item>
		</Item>
	</Item>
</Project>
