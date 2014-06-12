package com.oddcast.oc3d.shared
{
	// THIS CLASS HAS BEEN DEPRECATED,
	// use methods on the appropreate classes
	
	import com.oddcast.oc3d.data.*;
	import com.oddcast.oc3d.shared.*;
	
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class DataUtil
	{
		public static function accumulateString(fn:Function, init:String, l:*):String
		{
			var result:String = init;
			for (var i:uint=0; i<l.length; ++i) result = fn(l[i], result);
			return result;
		}
		
		public static function Matrix_toString(data:MatrixData):String
		{
			return "(matrix " + 
				data.n11 + " " + data.n12 + " " + data.n13 + " " + data.n14 + " " +
				data.n21 + " " + data.n22 + " " + data.n23 + " " + data.n24 + " " +
				data.n31 + " " + data.n32 + " " + data.n33 + " " + data.n34 + " " +
				data.n41 + " " + data.n42 + " " + data.n43 + " " + data.n44 + ")";
		}
		
		public static function JointEntry_toString(data:JointEntryData):String
		{
			return "(joint-entry-data (joint-index " + data.JointIndex + ") (weight " + data.Weight + "))";
		}
		
		public static function BlendedVertex_toString(data:BlendedVertexData):String
		{
			return "(blended-vertex-data (vertex-index " + data.VertexIndex + ") (joint-entries" +
				accumulateString(function(a:JointEntryData, b:String):String{ return b + " " + JointEntry_toString(a); }, "", data.JointEntries) + 
				"))";
		}
		
		public static function Skin_toString(data:SkinData):String
		{
			return "(skin-data (name \"" + data.Name + "\") (mesh-index " + data.MeshIndex + ") (joint-paths" + 
				accumulateString(function(a:String, b:String):String { return b + " \"" + a + "\""; }, "", data.JointPaths) + ") (joint-indices" +
				accumulateString(function(a:uint, b:String):String { return b + " " + a; }, "", data.JointIndices) + ") (bind-matrices" +
				accumulateString(function(a:MatrixData, b:String):String { return b + " " + Matrix_toString(a); }, "", data.BindMatrices) + ") (bind-matrix " + Matrix_toString(data.BindMatrix) + ") (blended-vertices" +
				accumulateString(function(a:BlendedVertexData, b:String):String { return b + " " + BlendedVertex_toString(a); }, "", data.BlendedVertices) +
				"))";
		}
		
		public static function Vector3D_toString(data:Vector3D):String
		{
			return "(vector3d " + data.x + " " + data.y + " " + data.z + ")";
		}
		
		public static function Mesh_toString(data:MeshData):String
		{
			return "(mesh-data (name \"" + data.Name + "\") (vertex-buffer" + 
				accumulateString(function(a:Vector3D, b:String):String { return b + " " + Vector3D_toString(a); }, "", data.VertexBuffer) + "))";
		}
		
		public static function Scene_toString(data:SceneData):String
		{
			return "(scene-data (name \"" + data.Name + "\") (skins" +
				accumulateString(function(a:SkinData, b:String):String { return b + " " + Skin_toString(a); }, "", data.Skins) + ") (meshes" +
				accumulateString(function(a:MeshData, b:String):String { return b + " " + Mesh_toString(a); }, "", data.Meshes) + "))";
		}
		
		// SERIALIZE

		public static function Avatar_serialize(output:ByteArray, data:AvatarData, version:uint):void
		{
			output.writeUTF(data.Name);
			serializeVector(output, version, data.Scenes, Scene_serialize);
			serializeVector(output, version, data.ContentNodes, ContentNode_serialize);
			serializeVector(output, version, data.ContentAssociations, ContentAssociation_serialize);
			serializeVector(output, version, data.VisemeMappings, VisemeMapping_serialize);
		}
		public static function ContentNode_serialize(output:ByteArray, data:ContentNodeData, version:uint):void
		{
			output.writeUTF(data.Type);
			output.writeInt(data.Id);
			output.writeUTF(data.Name);
			serializeVector(output, version, data.Properties, function(o:ByteArray, d:Vector.<String>, version:uint):void { serializeVector(o, version, d, function(o:ByteArray, s:String, version:uint):void { o.writeUTF(s); }); });
		}
		public static function ContentAssociation_serialize(output:ByteArray, data:ContentAssociationData, version:uint):void
		{
			output.writeUnsignedInt(data.ParentId);
			output.writeUnsignedInt(data.ChildId);
		}
		public static function VisemeMapping_serialize(output:ByteArray, data:VisemeMappingData, version:uint):void
		{
			output.writeUTF(data.MorphDeformerName);
			serializeVector(output, version, data.Entries, VisemeEntry_serialize);
		}
		public static function VisemeEntry_serialize(output:ByteArray, data:Vector.<String>, version:uint):void
		{
			output.writeUTF(data[0]);
			output.writeUTF(data[1]);
		}
		public static function Scene_serialize(output:ByteArray, data:SceneData, version:uint):void
		{
			output.writeUTF(data.Uri == null ? "" : data.Uri);
			output.writeUTF(data.Name);
			serializeVector(output, version, data.Nodes, Node_serialize);
			serializeVector(output, version, data.Skins, Skin_serialize);
			serializeVector(output, version, data.Morphs, Morph_serialize);
			serializeVector(output, version, data.Meshes, Mesh_serialize);
			serializeVector(output, version, data.Cameras, Camera_serialize);
			serializeVector(output, version, data.Lights, Light_serialize);
			serializeVector(output, version, data.Materials, Material_serialize);
			serializeVector(output, version, data.Animations, Animation_serialize);
		}
		public static function Frame_serialize(output:ByteArray, data:FrameData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			/*
			output.writeFloat(Utilities .trimNumber(data.FrameNumber));
			if (version < 5)
			{
				output.writeBoolean(data.Value is Number);
				if (data.Value is Number)
					output.writeFloat(Util.trimNumber(Number(data.Value)));
				else
					Matrix_serialize(output, MatrixData(data.Value), version);
			}
			else
			{
				if (data.Value is Number)
				{
					output.writeInt(FrameValueType.FLOAT);
					output.writeFloat(Util.trimNumber(Number(data.Value)));
				}
				else if (data.Value is MatrixData)
				{
					var pos:Vector3D = new Vector3D();
					var ori:Vector3D = new Vector3D(); // rads
					var scl:Vector3D = new Vector3D();
					Matrix_decomposeTransformToRadians(MatrixData(data.Value), pos, ori, scl);
					pos.x = Util.trimNumber(pos.x); pos.y = Util.trimNumber(pos.y); pos.z = Util.trimNumber(pos.z);
					ori.x = Util.trimNumber(ori.x); ori.y = Util.trimNumber(ori.y); ori.z = Util.trimNumber(ori.z);
					scl.x = Util.trimNumber(scl.x); scl.y = Util.trimNumber(scl.y); scl.z = Util.trimNumber(scl.z);
					
					var closeNuff:Function = function(num:Number, to:Number):Boolean { return (Math.abs(num - to) <= Maff.EPSILON); };
					var hasPos:Boolean = !closeNuff(pos.x, 0.0) || !closeNuff(pos.y, 0.0) || !closeNuff(pos.z, 0.0); 
					var hasOri:Boolean = !closeNuff(ori.x, 0.0) || !closeNuff(ori.y, 0.0) || !closeNuff(ori.z, 0.0);
					var hasScl:Boolean = !closeNuff(scl.x, 1.0) || !closeNuff(scl.y, 1.0) || !closeNuff(scl.z, 1.0);

					if (!hasPos && !hasOri && !hasScl)
						output.writeInt(FrameValueType.MATRIX_IDENTITY);
					else if (hasPos && hasOri && hasScl)
					{
						output.writeInt(FrameValueType.MATRIX);
						output.writeFloat(pos.x); output.writeFloat(pos.y); output.writeFloat(pos.z);
						output.writeFloat(ori.x); output.writeFloat(ori.y); output.writeFloat(ori.z);
						output.writeFloat(scl.x); output.writeFloat(scl.y); output.writeFloat(scl.z);
					}
					else if (hasPos && hasOri && !hasScl)
					{
						output.writeInt(FrameValueType.MATRIX_NO_SCALE);
						output.writeFloat(pos.x); output.writeFloat(pos.y); output.writeFloat(pos.z);
						output.writeFloat(ori.x); output.writeFloat(ori.y); output.writeFloat(ori.z);
					}
					else if (hasPos && !hasOri && hasScl)
					{
						output.writeInt(FrameValueType.MATRIX_NO_ORIENTATION);
						output.writeFloat(pos.x); output.writeFloat(pos.y); output.writeFloat(pos.z);
						output.writeFloat(scl.x); output.writeFloat(scl.y); output.writeFloat(scl.z);
					}
					else if (!hasPos && hasOri && hasScl)
					{
						output.writeFloat(pos.x); output.writeFloat(pos.y); output.writeFloat(pos.z);
						output.writeFloat(ori.x); output.writeFloat(ori.y); output.writeFloat(ori.z);
						output.writeFloat(scl.x); output.writeFloat(scl.y); output.writeFloat(scl.z);
					}
					else if (hasPos)
					{
						output.writeInt(FrameValueType.MATRIX_POSITION_ONLY);
						output.writeFloat(pos.x); output.writeFloat(pos.y); output.writeFloat(pos.z);
					}
					else if (hasOri)
					{
						output.writeInt(FrameValueType.MATRIX_ORIENTATION_ONLY);
						output.writeFloat(ori.x); output.writeFloat(ori.y); output.writeFloat(ori.z);
					}
					else if (hasScl)
					{
						output.writeInt(FrameValueType.MATRIX_SCALE_ONLY);
						output.writeFloat(scl.x); output.writeFloat(scl.y); output.writeFloat(scl.z);
					}
					else 
						throw new Error("unhandled matrix flag");
				}
				else
					throw new Error("failed to serialize frame - unknown frame-data-type");
				if (data.Value is Number)
				{
					output.writeInt(FrameValueType.FLOAT);
					output.writeFloat(Util.trimNumber(Number(data.Value)));
				}
				else if (data.Value is Matrix)
				{
					output.writeInt(FrameValueType.MATRIX);
					Matrix_serialize(output, MatrixData(data.Value), version);
				}
				else if (data.Value is FrameValueData)
				{
					output.writeInt(FrameValueType.FRAME_VALUE);
					FrameValue_serialize(output, FrameValueData(data.Value), version);
				}
				else
					throw new Error("failed to serialize frame unknown frame-data");
			}
			*/
		}
		public static function DeltaEntry_serialize(output:ByteArray, data:DeltaEntryData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			/*
			output.writeUnsignedInt(data.VertexIndex);
			output.writeFloat(Util.trimNumber(data.DeltaX));
			output.writeFloat(Util.trimNumber(data.DeltaY));
			output.writeFloat(Util.trimNumber(data.DeltaZ));
			*/
		}
		public static function JointEntry_serialize(output:ByteArray, data:JointEntryData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeUnsignedInt(data.JointIndex);
			//output.writeFloat(Util.trimNumber(data.Weight));
		}
		public static function Channel_serialize(output:ByteArray, data:ChannelData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeUnsignedInt(data.Type);
			//output.writeUTF(data.TargetPath);
			//serializeVector(output, version, data.Frames, Frame_serialize);
			//output.writeFloat(Util.trimNumber(data.Duration));
		}
		public static function Triangle_serialize(output:ByteArray, data:TriangleData, version:uint):void
		{
			output.writeUnsignedInt(data.VertexIndex0);
			output.writeUnsignedInt(data.VertexIndex1);
			output.writeUnsignedInt(data.VertexIndex2);
			output.writeUnsignedInt(data.UVIndex0);
			output.writeUnsignedInt(data.UVIndex1);
			output.writeUnsignedInt(data.UVIndex2);
			output.writeUnsignedInt(data.MaterialIndex);
			if (version >= 2)
			{
				output.writeUnsignedInt(data.UVIndex20);
				output.writeUnsignedInt(data.UVIndex21);
				output.writeUnsignedInt(data.UVIndex22);
			}
		}
		public static function UV_serialize(output:ByteArray, data:UVData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeFloat(Util.trimNumber(data.u));
			//output.writeFloat(Util.trimNumber(data.v));
		}
		public static function Vector3D_serialize(output:ByteArray, data:Vector3D, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeFloat(Util.trimNumber(data.x));
			//output.writeFloat(Util.trimNumber(data.y));
			//output.writeFloat(Util.trimNumber(data.z));
		}
		public static function Target_serialize(output:ByteArray, data:TargetData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeUTF(data.Name);
			//output.writeFloat(Util.trimNumber(data.InitialWeight));
			//serializeVector(output, version, data.DeltaEntries, DeltaEntry_serialize);
		}
		public static function BlendedVertex_serialize(output:ByteArray, data:BlendedVertexData, version:uint):void
		{
			output.writeUnsignedInt(data.VertexIndex);
			serializeVector(output, version, data.JointEntries, JointEntry_serialize);
		}
		public static function Animation_serialize(output:ByteArray, data:AnimationData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeFloat(Util.trimNumber(data.Duration));
			//serializeVector(output, version, data.Channels, Channel_serialize);
		}
		public static function Material_serialize(output:ByteArray, data:MaterialData, version:uint):void
		{
			output.writeUTF(data.Name);
			if (version >= 4)
				output.writeUTF(data.RealName==null ? data.Name : data.RealName);
		}
		public static function Light_serialize(output:ByteArray, data:LightData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeUTF(data.Name);
			//output.writeUnsignedInt(data.Type);
			//output.writeFloat(Util.trimNumber(data.Intensity));
			//output.writeUnsignedInt(data.ColorValue);
			//Vector3D_serialize(output, data.Target, version);
		}
		public static function Camera_serialize(output:ByteArray, data:CameraData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			//output.writeUTF(data.Name);
			//output.writeUnsignedInt(data.NodeIndex);
			//output.writeFloat(Util.trimNumber(data.AspectRatio));
			//output.writeFloat(Util.trimNumber(data.YFieldOfView));
			//output.writeFloat(Util.trimNumber(data.Near));
			//output.writeFloat(Util.trimNumber(data.Far));
		}
		public static function Mesh_serialize(output:ByteArray, data:MeshData, version:uint):void
		{
			if (version >= 3)
			{
				var maskIndex:int = -1;
				for (var mi:uint=0; mi<data.UVSetNames.length; ++mi)
				{
					if (data.UVSetNames[mi] == "mask")
					{
						maskIndex = mi;
						break;
					}
				}
				output.writeInt(maskIndex);
			}
			output.writeUTF(data.Name);
			serializeVector(output, version, data.UVSetNames, function(o:ByteArray, v:String, version:uint):void { o.writeUTF(v); });
			serializeVector(output, version, data.VertexBuffer, Vector3D_serialize);
			serializeVector(output, version, data.NormalBuffer, Vector3D_serialize);
			serializeVector(output, version, data.UVSetBuffers, function(o:ByteArray, v:Vector.<UVData>, version:uint):void { serializeVector(o, version, v, UV_serialize); });
			serializeVector(output, version, data.TriangleBuffer, Triangle_serialize);
			Vector3D_serialize(output, data.Minimum, version);
			Vector3D_serialize(output, data.Maximum, version);
			if (version >= 1)
				output.writeFloat(data.ZBias);
		}
		public static function Morph_serialize(output:ByteArray, data:MorphData, version:uint):void
		{
			output.writeUTF(data.Name);
			if (version >= 4)
				output.writeUTF(data.RealName==null ? data.Name : data.RealName);
			output.writeUnsignedInt(data.MeshIndex);
			serializeVector(output, version, data.Targets, Target_serialize);
		}
		public static function Skin_serialize(output:ByteArray, data:SkinData, version:uint):void
		{
			output.writeUTF(data.Name);
			if (version >= 4)
				output.writeUTF(data.RealName==null ? data.Name : data.RealName);
			output.writeUnsignedInt(data.MeshIndex);
			serializeVector(output, version, data.JointPaths, function(o:ByteArray, v:String, version:uint):void { o.writeUTF(v); });
			serializeVector(output, version, data.JointIndices, function(o:ByteArray, v:uint, version:uint):void { o.writeUnsignedInt(v); });
			serializeVector(output, version, data.BindMatrices, Matrix_serialize);
			Matrix_serialize(output, data.BindMatrix, version);
			serializeVector(output, version, data.BlendedVertices, BlendedVertex_serialize);
		}
		public static function Node_serialize(output:ByteArray, data:NodeData, version:uint):void
		{
			if (data.Name == null)
				output.writeUTF("");
			else
				output.writeUTF(data.Name);
			output.writeUnsignedInt(data.Type);
			output.writeInt(data.ParentIndex);
			Matrix_serialize(output, data.Transform, version);
			output.writeInt(data.MeshIndex);
		}
		/*
		public static function FrameValue_serialize(output:ByteArray, data:FrameValueData, version:uint):void
		{
			output.writeInt(data.ComponentFlag);
			for (var si:uint=0; si<data.Samples.length; ++si)
				CurveSample_serialize(output, data.Samples[si], version); 
		}
		public static function CurveSample_serialize(output:ByteArray, data:CurveSampleData, version:uint):void
		{
			output.writeInt(data.TangentMode);
			if (data.TangentMode == E.TangentMode_Spline)
			{
				output.writeFloat(Util.trimNumber(data.InTangentX));
				output.writeFloat(Util.trimNumber(data.InTangentY));
				output.writeFloat(Util.trimNumber(data.OutTangentX));
				output.writeFloat(Util.trimNumber(data.OutTangentY));
			}
			output.writeFloat(Util.trimNumber(data.Value));
		}*/
		public static function Matrix_serialize(output:ByteArray, mat:MatrixData, version:uint):void
		{
			throw new Error("deprecated - no longer in use");
			/*
			var closeNuff:Function = function(num:Number, to:Number):Boolean { return (Math.abs(num - to) <= Maff.EPSILON); };
			
			var n11:Number = mat.n11;
			var n12:Number = mat.n12;
			var n13:Number = mat.n13;
			var n14:Number = mat.n14;
			var n21:Number = mat.n21;
			var n22:Number = mat.n22;
			var n23:Number = mat.n23;
			var n24:Number = mat.n24;
			var n31:Number = mat.n31;
			var n32:Number = mat.n32;
			var n33:Number = mat.n33;
			var n34:Number = mat.n34;
			var n41:Number = mat.n41;
			var n42:Number = mat.n42;
			var n43:Number = mat.n43;
			var n44:Number = mat.n44;
			var flag:uint;
			
			var isIdentity:Boolean = 
				closeNuff(n11, 1.0) && closeNuff(n12, 0.0) && closeNuff(n13, 0.0) && closeNuff(n14, 0.0) &&
				closeNuff(n21, 0.0) && closeNuff(n22, 1.0) && closeNuff(n23, 0.0) && closeNuff(n24, 0.0) &&
				closeNuff(n31, 0.0) && closeNuff(n32, 0.0) && closeNuff(n33, 1.0) && closeNuff(n34, 0.0) &&
				closeNuff(n41, 0.0) && closeNuff(n42, 0.0) && closeNuff(n43, 0.0) && closeNuff(n44, 1.0);
			if (isIdentity)
				flag = 0;
			else
			{
				var isTransform:Boolean = closeNuff(n41, 0.0) && closeNuff(n42, 0.0) && closeNuff(n43, 0.0) && closeNuff(n44, 1.0);
				if (isTransform)
				{
					var isScale:Boolean =  
						closeNuff(n12, 0.0) && closeNuff(n13, 0.0) && closeNuff(n14, 0.0) &&
						closeNuff(n21, 0.0) && closeNuff(n23, 0.0) && closeNuff(n24, 0.0) && 
						closeNuff(n31, 0.0) && closeNuff(n32, 0.0) && closeNuff(n34, 0.0);
					if (isScale)
						flag = 1;
					else
					{
						var isTranslate:Boolean =
							closeNuff(n11, 1.0) && closeNuff(n12, 0.0) && closeNuff(n13, 0.0) &&
							closeNuff(n21, 0.0) && closeNuff(n22, 1.0) && closeNuff(n23, 0.0) &&
							closeNuff(n31, 0.0) && closeNuff(n32, 0.0) && closeNuff(n33, 1.0);
						if (isTranslate)
							flag = 2;
						else
							flag = 3;
					}
				}
				else
					flag = 4;
			}
			
			output.writeByte(flag);
			if (flag == 0) // is identity
				return;
			else if (flag == 1) // is scale
			{
				output.writeFloat(Util.trimNumber(n11, 100000));
				output.writeFloat(Util.trimNumber(n22, 100000));
				output.writeFloat(Util.trimNumber(n33, 100000));
			}
			else if (flag == 2) // is translate
			{
				output.writeFloat(Util.trimNumber(n14, 100000));
				output.writeFloat(Util.trimNumber(n24, 100000));
				output.writeFloat(Util.trimNumber(n34, 100000));
			}
			else if (flag == 3) // is 3x4
			{
				output.writeFloat(Util.trimNumber(n11, 100000));
				output.writeFloat(Util.trimNumber(n12, 100000));
				output.writeFloat(Util.trimNumber(n13, 100000));
				output.writeFloat(Util.trimNumber(n14, 100000));
				output.writeFloat(Util.trimNumber(n21, 100000));
				output.writeFloat(Util.trimNumber(n22, 100000));
				output.writeFloat(Util.trimNumber(n23, 100000));
				output.writeFloat(Util.trimNumber(n24, 100000));
				output.writeFloat(Util.trimNumber(n31, 100000));
				output.writeFloat(Util.trimNumber(n32, 100000));
				output.writeFloat(Util.trimNumber(n33, 100000));
				output.writeFloat(Util.trimNumber(n34, 100000));
			}
			else // is 4x4
			{
				output.writeFloat(Util.trimNumber(n11, 100000));
				output.writeFloat(Util.trimNumber(n12, 100000));
				output.writeFloat(Util.trimNumber(n13, 100000));
				output.writeFloat(Util.trimNumber(n14, 100000));
				output.writeFloat(Util.trimNumber(n21, 100000));
				output.writeFloat(Util.trimNumber(n22, 100000));
				output.writeFloat(Util.trimNumber(n23, 100000));
				output.writeFloat(Util.trimNumber(n24, 100000));
				output.writeFloat(Util.trimNumber(n31, 100000));
				output.writeFloat(Util.trimNumber(n32, 100000));
				output.writeFloat(Util.trimNumber(n33, 100000));
				output.writeFloat(Util.trimNumber(n34, 100000));
				output.writeFloat(Util.trimNumber(n41, 100000));
				output.writeFloat(Util.trimNumber(n42, 100000));
				output.writeFloat(Util.trimNumber(n43, 100000));
				output.writeFloat(Util.trimNumber(n44, 100000));
			}
			*/
		}
		
		// DESERIALIZE
		public static function Avatar_deserialize(input:ByteArray, version:uint):AvatarData
		{
			var result:AvatarData = new AvatarData();
			result.Name = input.readUTF();
			result.Scenes = deserializeVectorSceneData(input, version, Scene_deserialize);
			result.ContentNodes = deserializeVectorContentNodeData(input, version, ContentNode_deserialize);
			result.ContentAssociations = deserializeVectorContentAssociationData(input, version, ContentAssociation_deserialize);
			if (input.bytesAvailable > 0)
				result.VisemeMappings = deserializeVectorVisemeMappingData(input, version, VisemeMapping_deserialize);
			return result;
		}
		public static function ContentAssociation_deserialize(input:ByteArray, version:uint):ContentAssociationData
		{
			var result:ContentAssociationData = new ContentAssociationData();
			result.ParentId = input.readUnsignedInt();
			result.ChildId = input.readUnsignedInt();
			return result;
		}
		public static function VisemeMapping_deserialize(input:ByteArray, version:uint):VisemeMappingData
		{
			var result:VisemeMappingData = new VisemeMappingData();
			result.MorphDeformerName = input.readUTF();
			result.Entries = deserializeVectorVisemeEntry(input, version, VisemeEntry_deserialize);
			return result;
		}
		public static function VisemeEntry_deserialize(input:ByteArray, version:uint):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>(2, true);
			result[0] = input.readUTF();
			result[1] = input.readUTF();
			return result;
		}
		public static function Scene_deserialize(input:ByteArray, version:uint):SceneData
		{
			var result:SceneData = new SceneData();
			result.Uri = input.readUTF();
			result.Uri = result.Uri.length == 0 ? null : result.Uri;
			result.Name = input.readUTF();
			result.Nodes = deserializeVectorNodeData(input, version, Node_deserialize);
			result.Skins = deserializeVectorSkinData(input, version, Skin_deserialize);
			result.Morphs = deserializeVectorMorphData(input, version, Morph_deserialize);
			result.Meshes = deserializeVectorMeshData(input, version, Mesh_deserialize);
			result.Cameras = deserializeVectorCameraData(input, version, Camera_deserialize);
			result.Lights = deserializeVectorLightData(input, version, Light_deserialize);
			result.Materials = deserializeVectorMaterialData(input, version, Material_deserialize);
			result.Animations = deserializeVectorAnimationData(input, version, Animation_deserialize);
			return result;
		}
		public static function ContentNode_deserialize(input:ByteArray, version:uint):ContentNodeData
		{
			var result:ContentNodeData = new ContentNodeData();
			result.Type = input.readUTF();
			result.Id = input.readInt();
			result.Name = input.readUTF();
			result.Properties = deserializeVectorVectorString(input, version, function(i:ByteArray, version:uint):Vector.<String> { return deserializeVectorString(i, version, function(i:ByteArray, version:uint):String { return i.readUTF(); }); });
			return result;
		}
		/*
		public static function FrameValue_deserialize(input:ByteArray, version:uint):FrameValueData
		{
			var result:FrameValueData = new FrameValueData();
			result.ComponentFlag = input.readInt();
			if (result.ComponentFlag == 7)
			{
				result.Samples = new Vector.<CurveSampleData>(3);
				result.Samples[0] = CurveSample_deserialize(input, version);
				result.Samples[1] = CurveSample_deserialize(input, version);
				result.Samples[2] = CurveSample_deserialize(input, version);
			}
			else if (result.ComponentFlag == 6 || result.ComponentFlag == 5 || result.ComponentFlag == 3)
			{
				result.Samples = new Vector.<CurveSampleData>(2);
				result.Samples[0] = CurveSample_deserialize(input, version);
				result.Samples[1] = CurveSample_deserialize(input, version);
			}
			else if (result.ComponentFlag == 4 || result.ComponentFlag == 2 || result.ComponentFlag == 1)
			{
				result.Samples = new Vector.<CurveSampleData>(1);
				result.Samples[0] = CurveSample_deserialize(input, version);
			}
			return result;
		}
		public static function CurveSample_deserialize(input:ByteArray, version:uint):CurveSampleData
		{
			var result:CurveSampleData = new CurveSampleData();
			result.TangentMode = input.readInt();
			if (result.TangentMode == E.TangentMode_Spline)
			{
				result.InTangentX = input.readFloat();
				result.InTangentY = input.readFloat();
				result.OutTangentX = input.readFloat();
				result.OutTangentY = input.readFloat();
			}
			else
			{
				result.InTangentX = 0;
				result.InTangentY = 0;
				result.OutTangentX = 0;
				result.OutTangentY = 0;
			}
			result.Value = input.readFloat();
			return result;
		}*/
		public static function Matrix_deserialize(input:ByteArray, version:uint):MatrixData
		{
			var result:MatrixData = new MatrixData();
			result.n11 = result.n22 = result.n33 = result.n44 = 1;
			result.n12 = result.n13 = result.n14 = result.n21 = result.n23 = result.n24 = result.n31 = result.n32 = result.n34 = result.n41 = result.n42 = result.n43 = 0;
			
			var flag:int = input.readByte();
			if (flag == 0) // is identity
				return result;
			else if (flag == 1) // is scale
			{
				result.n11 = input.readFloat();
				result.n22 = input.readFloat();
				result.n33 = input.readFloat();
			}
			else if (flag == 2) // is translate
			{
				result.n11 = result.n22 = result.n33 = result.n44 = 1;
				result.n14 = input.readFloat();
				result.n24 = input.readFloat();
				result.n34 = input.readFloat();
			}
			else if (flag == 3) // is 3x4
			{
				result.n11 = input.readFloat();
				result.n12 = input.readFloat();
				result.n13 = input.readFloat();
				result.n14 = input.readFloat();
				result.n21 = input.readFloat();
				result.n22 = input.readFloat();
				result.n23 = input.readFloat();
				result.n24 = input.readFloat();
				result.n31 = input.readFloat();
				result.n32 = input.readFloat();
				result.n33 = input.readFloat();
				result.n34 = input.readFloat();
			}
			else if (flag == 4) // is 4x4
			{
				result.n11 = input.readFloat();
				result.n12 = input.readFloat();
				result.n13 = input.readFloat();
				result.n14 = input.readFloat();
				result.n21 = input.readFloat();
				result.n22 = input.readFloat();
				result.n23 = input.readFloat();
				result.n24 = input.readFloat();
				result.n31 = input.readFloat();
				result.n32 = input.readFloat();
				result.n33 = input.readFloat();
				result.n34 = input.readFloat();
				result.n41 = input.readFloat();
				result.n42 = input.readFloat();
				result.n43 = input.readFloat();
				result.n44 = input.readFloat();
			}
			return result;
		}
		
		public static function Frame_deserialize(input:ByteArray, version:uint):FrameData
		{
			throw new Error("deprecated - no longer in use");
			/*
			var result:FrameData = new FrameData();
			result.FrameNumber = input.readFloat();
			if (version < 5)
			{
				if (input.readBoolean())
					result.Value = input.readFloat();
				else
					result.Value = Matrix_deserialize(input, version);
			}
			else
			{
				var posX:Number; var posY:Number; var posZ:Number;
				var radX:Number; var radY:Number; var radZ:Number;
				var sclX:Number; var sclY:Number; var sclZ:Number;
				
				var type:int = input.readInt();
				if (type == FrameValueType.FLOAT)
					result.Value = input.readFloat();
				else if (type == FrameValueType.MATRIX_IDENTITY)
					result.Value = Matrix_createIdentity();
				else if (type == FrameValueType.MATRIX)
				{
					posX = input.readFloat(); posY = input.readFloat(); posZ = input.readFloat();
					radX = input.readFloat(); radY = input.readFloat(); radZ = input.readFloat();
					sclX = input.readFloat(); sclY = input.readFloat(); sclZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(posX, posY, posZ, radX, radY, radZ, sclX, sclY, sclZ);
				}
				else if (type == FrameValueType.MATRIX_NO_POSITION)
				{
					radX = input.readFloat(); radY = input.readFloat(); radZ = input.readFloat();
					sclX = input.readFloat(); sclY = input.readFloat(); sclZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(0, 0, 0, radX, radY, radZ, sclX, sclY, sclZ);
				}
				else if (type == FrameValueType.MATRIX_NO_ORIENTATION)
				{
					posX = input.readFloat(); posY = input.readFloat(); posZ = input.readFloat();
					sclX = input.readFloat(); sclY = input.readFloat(); sclZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(posX, posY, posZ, 0, 0, 0, sclX, sclY, sclZ);
				}
				else if (type == FrameValueType.MATRIX_NO_SCALE)
				{
					posX = input.readFloat(); posY = input.readFloat(); posZ = input.readFloat();
					radX = input.readFloat(); radY = input.readFloat(); radZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(posX, posY, posZ, radX, radY, radZ, 1, 1, 1);
				}
				else if (type == FrameValueType.MATRIX_POSITION_ONLY)
				{
					posX = input.readFloat(); posY = input.readFloat(); posZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(posX, posY, posZ, 0, 0, 0, 1, 1, 1);
				}
				else if (type == FrameValueType.MATRIX_ORIENTATION_ONLY)
				{
					radX = input.readFloat(); radY = input.readFloat(); radZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(0, 0, 0, radX, radY, radZ, 1, 1, 1);
				}
				else if (type == FrameValueType.MATRIX_SCALE_ONLY)
				{
					sclX = input.readFloat(); sclY = input.readFloat(); sclZ = input.readFloat();
					result.Value = Matrix_composeTransformWithRadians(0, 0, 0, 0, 0, 0, sclX, sclY, sclZ);
				}
				else
					throw new Error("failed to deserialize frame - unknown frame-data-type");
			}
			else
			{
				var type:int = input.readInt();
				if (type == FrameValueType.FLOAT)
					result.Value = input.readFloat();
				else if (type == FrameValueType.MATRIX)
					result.Value = Matrix_deserialize(input, version);
				else if (type == FrameValueType.FRAME_VALUE)
					result.Value = FrameValue_deserialize(input, version);
				else
					throw new Error("failed to deserialize frame - unknown frame-data");
			}
			return result;
			*/
		}
		public static function DeltaEntry_deserialize(input:ByteArray, version:uint):DeltaEntryData
		{
			var result:DeltaEntryData = new DeltaEntryData();
			result.VertexIndex = input.readUnsignedInt();
			result.DeltaX = input.readFloat();
			result.DeltaY = input.readFloat();
			result.DeltaZ = input.readFloat();
			return result;
		}
		public static function JointEntry_deserialize(input:ByteArray, version:uint):JointEntryData
		{
			var result:JointEntryData = new JointEntryData();
			result.JointIndex = input.readUnsignedInt();
			result.Weight = input.readFloat();
			return result;
		}
		public static function Channel_deserialize(input:ByteArray, version:uint):ChannelData
		{
			var result:ChannelData = new ChannelData();
			result.Type = input.readUnsignedInt();
			result.TargetPath = input.readUTF();
			result.Frames = deserializeVectorFrameData(input, version, Frame_deserialize);
			result.Duration = input.readFloat();
			return result;
		}
		public static function Triangle_deserialize(input:ByteArray, version:uint):TriangleData
		{
			var result:TriangleData = new TriangleData();
			result.VertexIndex0 = input.readUnsignedInt();
			result.VertexIndex1 = input.readUnsignedInt();
			result.VertexIndex2 = input.readUnsignedInt();
			result.UVIndex0 = input.readUnsignedInt();
			result.UVIndex1 = input.readUnsignedInt();
			result.UVIndex2 = input.readUnsignedInt();
			result.MaterialIndex = input.readUnsignedInt();
			if (version >= 2)
			{
				result.UVIndex20 = input.readUnsignedInt();
				result.UVIndex21 = input.readUnsignedInt();
				result.UVIndex22 = input.readUnsignedInt();
			}
			return result;
		}
		public static function UV_deserialize(input:ByteArray, version:uint):UVData
		{
			var result:UVData = new UVData();
			result.u = input.readFloat();
			result.v = input.readFloat();
			return result;
		}
		public static function Vector3D_deserialize(input:ByteArray, version:uint):Vector3D
		{
			return new Vector3D(input.readFloat(), input.readFloat(), input.readFloat());
		}
		public static function Target_deserialize(input:ByteArray, version:uint):TargetData
		{
			var result:TargetData = new TargetData();
			result.Name = input.readUTF();
			result.InitialWeight = input.readFloat();
			result.DeltaEntries = deserializeVectorDeltaEntryData(input, version, DeltaEntry_deserialize);
			return result;
		}
		public static function BlendedVertex_deserialize(input:ByteArray, version:uint):BlendedVertexData
		{
			var result:BlendedVertexData = new BlendedVertexData();
			result.VertexIndex = input.readUnsignedInt();
			result.JointEntries = deserializeVectorJointEntryData(input, version, JointEntry_deserialize);
			return result;
		}
		public static function Animation_deserialize(input:ByteArray, version:uint):AnimationData
		{
			var result:AnimationData = new AnimationData();
			result.Duration = input.readFloat();
			result.Channels = deserializeVectorChannelData(input, version, Channel_deserialize);
			return result;
		}
		public static function Material_deserialize(input:ByteArray, version:uint):MaterialData
		{
			var result:MaterialData = new MaterialData();
			result.Name = input.readUTF();
			if (version >= 4)
				result.RealName = input.readUTF();
			else
				result.RealName = result.Name;
			return result;
		}
		public static function Light_deserialize(input:ByteArray, version:uint):LightData
		{
			var result:LightData = new LightData();
			result.Name = input.readUTF();
			result.Type = input.readUnsignedInt();
			result.Intensity = input.readFloat();
			result.ColorValue = input.readUnsignedInt();
			result.Target = Vector3D_deserialize(input, version);
			return result;
		}
		public static function Camera_deserialize(input:ByteArray, version:uint):CameraData
		{
			var result:CameraData = new CameraData();
			result.Name = input.readUTF();
			result.NodeIndex = input.readUnsignedInt();
			result.AspectRatio = input.readFloat();
			result.YFieldOfView = input.readFloat();
			result.Near = input.readFloat();
			result.Far = input.readFloat();
			return result;
		}
		public static function Mesh_deserialize(input:ByteArray, version:uint):MeshData
		{
			var result:MeshData = new MeshData();
			result.MaskUVSetIndex = version >= 3 ? input.readInt() : -1;
			result.Name = input.readUTF();
			result.UVSetNames = deserializeVectorString(input, version, function(i:ByteArray, version:uint):String{ return i.readUTF(); });
			result.VertexBuffer = deserializeVectorVector3D(input, version, Vector3D_deserialize);
			result.NormalBuffer = deserializeVectorVector3D(input, version, Vector3D_deserialize);
			result.UVSetBuffers = deserializeVectorVectorUVData(input, version, function(i:ByteArray, version:uint):Vector.<UVData>{ return deserializeVectorUVData(i, version, UV_deserialize); });
			result.TriangleBuffer = deserializeVectorTriangleData(input, version, Triangle_deserialize);
			result.Minimum = Vector3D_deserialize(input, version);
			result.Maximum = Vector3D_deserialize(input, version);
			if (version >= 1)
				result.ZBias = input.readFloat();
			return result;
		}
		public static function Morph_deserialize(input:ByteArray, version:uint):MorphData
		{
			var result:MorphData = new MorphData();
			result.Name = input.readUTF();
			if (version >= 4)
				result.RealName = input.readUTF();
			else
				result.RealName = result.Name;
			result.MeshIndex = input.readUnsignedInt();
			result.Targets = deserializeVectorTargetData(input, version, Target_deserialize);
			return result;
		}
		public static function Skin_deserialize(input:ByteArray, version:uint):SkinData
		{
			var result:SkinData = new SkinData();
			result.Name = input.readUTF();
			if (version >= 4)
				result.RealName = input.readUTF();
			else
				result.RealName = result.Name;
			result.MeshIndex = input.readUnsignedInt();
			result.JointPaths = deserializeVectorString(input, version, function(i:ByteArray, version:uint):String { return i.readUTF(); });
			result.JointIndices = deserializeVectorUInt(input, version, function(i:ByteArray, version:uint):uint { return i.readUnsignedInt(); });
			result.BindMatrices = deserializeVectorMatrixData(input, version, Matrix_deserialize);
			result.BindMatrix = Matrix_deserialize(input, version);
			result.BlendedVertices = deserializeVectorBlendedVertexData(input, version, BlendedVertex_deserialize);
			return result;
		}
		public static function Node_deserialize(input:ByteArray, version:uint):NodeData
		{
			var result:NodeData = new NodeData();
			result.Name = input.readUTF();
			if (result.Name == "")
				result.Name = null;
			result.Type = input.readUnsignedInt();
			result.ParentIndex = input.readInt();
			result.Transform = Matrix_deserialize(input, version);
			result.MeshIndex = input.readInt();
			return result;
		}
		
		
		// CLONING
		
		public static function Avatar_clone(data:AvatarData):AvatarData
		{
			var result:AvatarData = new AvatarData();
			result.Name = data.Name;
			if (data.Scenes != null)
			{
				result.Scenes = new Vector.<SceneData>(data.Scenes.length, true);
				for (var i:uint=0; i<data.Scenes.length; ++i)
					result.Scenes[i] = Scene_clone(data.Scenes[i]);
			}
			if (data.ContentNodes != null)
			{
				result.ContentNodes = new Vector.<ContentNodeData>(data.ContentNodes.length, true);
				for (var j:uint=0; j<data.ContentNodes.length; ++j)
					result.ContentNodes[j] = ContentNode_clone(data.ContentNodes[j]);
			}
			if (data.ContentAssociations != null)
			{
				result.ContentAssociations = new Vector.<ContentAssociationData>(data.ContentAssociations.length, true);
				for (var k:uint=0; k<data.ContentAssociations.length; ++k)
					result.ContentAssociations[k] = ContentAssociation_clone(data.ContentAssociations[k]);
			}
			return result;
		}
		public static function ContentAssociation_clone(data:ContentAssociationData):ContentAssociationData
		{
			var result:ContentAssociationData = new ContentAssociationData();
			result.ParentId = data.ParentId;
			result.ChildId = data.ChildId;
			return result;
		}
		public static function ContentNode_clone(data:ContentNodeData):ContentNodeData
		{
			var result:ContentNodeData = new ContentNodeData();
			result.Type = data.Type;
			result.Id = data.Id;
			result.Name = data.Name;
			if (data.Properties != null)
			{
				result.Properties = new Vector.<Vector.<String>>(data.Properties.length, true);
				for (var i:uint=0; i<data.Properties.length; ++i)
				{
					var prop:Vector.<String> = data.Properties[i];
					var property:Vector.<String> = result.Properties[i] = new Vector.<String>(prop.length, true);
					for (var j:uint=0; j<prop.length; ++j)
						property[j] = prop[j];	
				}
			}
			return result;
		}
		public static function Target_clone(data:TargetData):TargetData
		{
			var result:TargetData = new TargetData();
			result.Name = data.Name;
			result.InitialWeight = data.InitialWeight;
			if (data.DeltaEntries != null)
			{
				result.DeltaEntries = new Vector.<DeltaEntryData>(data.DeltaEntries.length, true);
				for (var i:uint=0; i<data.DeltaEntries.length; ++i)
					result.DeltaEntries[i] = DeltaEntry_clone(data.DeltaEntries[i]);
			}
			return result;
		}
		public static function Morph_clone(data:MorphData):MorphData
		{
			var result:MorphData = new MorphData();
			result.Name = data.Name;
			result.MeshIndex = data.MeshIndex;
			if (data.Targets != null)
			{
				result.Targets = new Vector.<TargetData>(data.Targets.length, true);
				for (var i:uint=0; i<data.Targets.length; ++i)
					result.Targets[i] = Target_clone(data.Targets[i]);
			}
			return result;
		}
		public static function BlendedVertex_clone(data:BlendedVertexData):BlendedVertexData
		{
			var result:BlendedVertexData = new BlendedVertexData();
			result.VertexIndex = data.VertexIndex;
			if (data.JointEntries != null)
			{
				result.JointEntries = new Vector.<JointEntryData>(data.JointEntries.length, true);
				for (var i:uint=0; i<data.JointEntries.length; ++i)
					result.JointEntries[i] = JointEntry_clone(data.JointEntries[i]);
			}
			return result;
		}
		public static function Skin_clone(data:SkinData):SkinData
		{
			var i:uint;
			var result:SkinData = new SkinData();
			result.Name = data.Name;
			result.MeshIndex = data.MeshIndex;
			if (data.JointPaths != null)
			{
				result.JointPaths = new Vector.<String>(data.JointPaths.length, true);
				for (i=0; i<data.JointPaths.length; ++i)
					result.JointPaths[i] = data.JointPaths[i];
			}
			if (data.JointIndices != null)
			{
				result.JointIndices = new Vector.<uint>(data.JointIndices.length, true);
				for (i=0; i<data.JointIndices.length; ++i)
					result.JointIndices[i] = data.JointIndices[i];
			}
			if (data.BindMatrices != null)
			{
				result.BindMatrices = new Vector.<MatrixData>(data.BindMatrices.length, true);
				for (i=0; i<data.BindMatrices.length; ++i)
					result.BindMatrices[i] = Matrix_clone(data.BindMatrices[i]);
			}
			result.BindMatrix = Matrix_clone(data.BindMatrix);
			if (data.BlendedVertices != null)
			{
				result.BlendedVertices = new Vector.<BlendedVertexData>(data.BlendedVertices.length, true);
				for (i=0; i<data.BlendedVertices.length; ++i)
					result.BlendedVertices[i] = BlendedVertex_clone(data.BlendedVertices[i]);
			}
			return result;
		}
		public static function Node_clone(data:NodeData):NodeData
		{
			var result:NodeData = new NodeData();
			result.Name = data.Name;
			result.Type = data.Type;
			result.ParentIndex = data.ParentIndex;
			if (data.Transform != null)
				result.Transform = Matrix_clone(data.Transform);
			result.MeshIndex = data.MeshIndex;
			return result;
		}
		public static function Scene_clone(data:SceneData):SceneData
		{
			var i:uint;
			var result:SceneData = new SceneData();
			result.Uri = data.Uri;
			result.Name = data.Name;
			if (data.Nodes != null)
			{
				result.Nodes = new Vector.<NodeData>(data.Nodes.length, true);
				for (i=0; i<data.Nodes.length; ++i)
					result.Nodes[i] = Node_clone(data.Nodes[i]);
			}
			if (data.Skins != null)
			{
				result.Skins = new Vector.<SkinData>(data.Skins.length, true);
				for (i=0; i<data.Skins.length; ++i)
					result.Skins[i] = Skin_clone(data.Skins[i]);
			}
			if (data.Morphs != null)
			{
				result.Morphs = new Vector.<MorphData>(data.Morphs.length, true);
				for (i=0; i<data.Morphs.length; ++i)
					result.Morphs[i] = Morph_clone(data.Morphs[i]);
			}
			if (data.Meshes != null)
			{
				result.Meshes = new Vector.<MeshData>(data.Meshes.length, true);
				for (i=0; i<data.Meshes.length; ++i)
					result.Meshes[i] = Mesh_clone(data.Meshes[i]);
			}
			if (data.Cameras != null)
			{
				result.Cameras = new Vector.<CameraData>(data.Cameras.length, true);
				for (i=0; i<data.Cameras.length; ++i)
					result.Cameras[i] = Camera_clone(data.Cameras[i]);
			}
			if (data.Lights != null)
			{
				result.Lights = new Vector.<LightData>(data.Lights.length, true);
				for (i=0; i<data.Lights.length; ++i)
					result.Lights[i] = Light_clone(data.Lights[i]);
			}
			if (data.Materials != null)
			{
				result.Materials = new Vector.<MaterialData>(data.Materials.length, true);
				for (i=0; i<data.Materials.length; ++i)
					result.Materials[i] = Material_clone(data.Materials[i]);
			}
			if (data.Animations != null)
			{
				result.Animations = new Vector.<AnimationData>(data.Animations.length, true);
				for (i=0; i<data.Animations.length; ++i)
					result.Animations[i] = Animation_clone(data.Animations[i]);
			}
			return result;
		}
		public static function Mesh_clone(data:MeshData):MeshData
		{
			var i:uint;
			var result:MeshData = new MeshData();
			result.MaskUVSetIndex = data.MaskUVSetIndex;
			result.Name = data.Name;
			if (data.UVSetNames != null)
			{
				result.UVSetNames = new Vector.<String>(data.UVSetNames.length, true);
				for (i=0; i<data.UVSetNames.length; ++i)
					result.UVSetNames[i] = data.UVSetNames[i];
			}
			if (data.VertexBuffer != null)
			{
				result.VertexBuffer = new Vector.<Vector3D>(data.VertexBuffer.length, true);
				for (i=0; i<data.VertexBuffer.length; ++i)
					result.VertexBuffer[i] = Maff.Vector3D_clone(data.VertexBuffer[i]);
			}
			if (data.NormalBuffer != null)
			{
				result.NormalBuffer = new Vector.<Vector3D>(data.NormalBuffer.length, true);
				for (i=0; i<data.NormalBuffer.length; ++i)
					result.NormalBuffer[i] = Maff.Vector3D_clone(data.NormalBuffer[i]);
			}
			if (data.UVSetBuffers != null)
			{
				result.UVSetBuffers = new Vector.<Vector.<UVData>>(data.UVSetBuffers.length, true);
				for (i=0; i<data.UVSetBuffers.length; ++i)
				{
					var buf:Vector.<UVData> = data.UVSetBuffers[i];
					var buffer:Vector.<UVData> = result.UVSetBuffers[i] = new Vector.<UVData>(buf.length, true);
					for (var j:uint=0; j<buffer.length; ++j)
						buffer[j] = UV_clone(buf[j]);
				}
			}
			if (data.TriangleBuffer != null)
			{
				result.TriangleBuffer = new Vector.<TriangleData>(data.TriangleBuffer.length, true);
				for (i=0; i<data.TriangleBuffer.length; ++i)
					result.TriangleBuffer[i] = Triangle_clone(data.TriangleBuffer[i]);
			}
			if (data.Minimum != null)
				result.Minimum = Maff.Vector3D_clone(data.Minimum);
			if (data.Maximum != null)
				result.Maximum = Maff.Vector3D_clone(data.Maximum);
			return result;
		}
		public static function Camera_clone(data:CameraData):CameraData
		{
			var result:CameraData = new CameraData();
			result.Name = data.Name;
			result.NodeIndex = data.NodeIndex;
			result.AspectRatio = data.AspectRatio;
			result.YFieldOfView = data.YFieldOfView;
			result.Near = data.Near;
			result.Far = data.Far;
			return result;
		}
		public static function Light_clone(data:LightData):LightData
		{
			var result:LightData = new LightData();
			result.Name = data.Name;
			result.Type = data.Type;
			result.Intensity = data.Intensity;
			result.ColorValue = data.ColorValue;
			if (result.Target != null)
				result.Target = Maff.Vector3D_clone(data.Target); 
			return result
		}
		public static function Material_clone(data:MaterialData):MaterialData
		{
			var result:MaterialData = new MaterialData();
			result.Name = data.Name;
			return result;
		}
		public static function Channel_clone(data:ChannelData):ChannelData
		{
			var result:ChannelData = new ChannelData();
			result.Type = data.Type;
			result.TargetPath = data.TargetPath;
			if (data.Frames != null)
			{
				result.Frames = new Vector.<FrameData>(data.Frames.length, true);
				for (var i:uint=0; i<data.Frames.length; ++i)
					result.Frames[i] = Frame_clone(data.Frames[i]);
			}
			return result;
		}
		public static function Animation_clone(data:AnimationData):AnimationData
		{
			var result:AnimationData = new AnimationData();
			result.Duration = data.Duration;
			if (data.Channels != null)
			{
				result.Channels = new Vector.<ChannelData>(data.Channels.length, true);
				for (var i:uint=0; i<data.Channels.length; ++i)
					result.Channels[i] = Channel_clone(data.Channels[i]);
			}
			return result;
		}
		public static function DeltaEntry_clone(data:DeltaEntryData):DeltaEntryData
		{
			var result:DeltaEntryData = new DeltaEntryData();
			result.VertexIndex = data.VertexIndex;
			result.DeltaX = data.DeltaX;
			result.DeltaY = data.DeltaY;
			result.DeltaZ = data.DeltaZ;
			return result;
		}
		public static function Frame_clone(data:FrameData):FrameData
		{
			var result:FrameData = new FrameData();
			result.FrameNumber = data.FrameNumber;
			if (data.Value is Number)
				result.Value = data.Value;
			else // is MatrixData
				result.Value = Matrix_clone(data.Value);
			return result;
		}
		public static function JointEntry_clone(data:JointEntryData):JointEntryData
		{
			var result:JointEntryData = new JointEntryData();
			result.JointIndex = data.JointIndex;
			result.Weight = data.Weight;
			return result;
		}
		public static function Triangle_clone(data:TriangleData):TriangleData
		{
			var result:TriangleData = new TriangleData();
			result.VertexIndex0 = data.VertexIndex0;
			result.VertexIndex1 = data.VertexIndex1;
			result.VertexIndex2 = data.VertexIndex2;
			result.UVIndex0 = data.UVIndex0;
			result.UVIndex1 = data.UVIndex1;
			result.UVIndex2 = data.UVIndex2;
			result.MaterialIndex = data.MaterialIndex;
			result.UVIndex20 = data.UVIndex20;
			result.UVIndex21 = data.UVIndex21;
			result.UVIndex22 = data.UVIndex22;
			return result;
		}
		public static function UV_clone(data:UVData):UVData 
		{
			var result:UVData = new UVData();
			result.u = data.u;
			result.v = data.v;
			return result;
		}
		public static function Matrix_clone(mat:MatrixData):MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assign(result, mat);
			return result;
		}
		
		// HELPERS ///////////////////////////////////////////////////////////////////
		private static function deserializeVectorVectorString(input:ByteArray, version:uint, deserializeFn:Function):Vector.<Vector.<String>>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorString(input:ByteArray, version:uint, deserializeFn:Function):Vector.<String>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<String> = new Vector.<String>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorSceneData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<SceneData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<SceneData> = new Vector.<SceneData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorContentNodeData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<ContentNodeData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<ContentNodeData> = new Vector.<ContentNodeData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorContentAssociationData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<ContentAssociationData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<ContentAssociationData> = new Vector.<ContentAssociationData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorVisemeMappingData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<VisemeMappingData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<VisemeMappingData> = new Vector.<VisemeMappingData>(count, true);
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorVisemeEntry(input:ByteArray, version:uint, deserializeFn:Function):Vector.<Vector.<String>>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<Vector.<String>> = new Vector.<Vector.<String>>(count, true);
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorNodeData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<NodeData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<NodeData> = new Vector.<NodeData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorSkinData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<SkinData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<SkinData> = new Vector.<SkinData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorMorphData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<MorphData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<MorphData> = new Vector.<MorphData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorMeshData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<MeshData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<MeshData> = new Vector.<MeshData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorCameraData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<CameraData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<CameraData> = new Vector.<CameraData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorLightData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<LightData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<LightData> = new Vector.<LightData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorMaterialData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<MaterialData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<MaterialData> = new Vector.<MaterialData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorAnimationData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<AnimationData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<AnimationData> = new Vector.<AnimationData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorUInt(input:ByteArray, version:uint, deserializeFn:Function):Vector.<uint>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<uint> = new Vector.<uint>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorMatrixData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<MatrixData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<MatrixData> = new Vector.<MatrixData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorBlendedVertexData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<BlendedVertexData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<BlendedVertexData> = new Vector.<BlendedVertexData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorTargetData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<TargetData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<TargetData> = new Vector.<TargetData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorVector3D(input:ByteArray, version:uint, deserializeFn:Function):Vector.<Vector3D>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<Vector3D> = new Vector.<Vector3D>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorVectorUVData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<Vector.<UVData>>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<Vector.<UVData>> = new Vector.<Vector.<UVData>>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorUVData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<UVData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<UVData> = new Vector.<UVData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorTriangleData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<TriangleData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<TriangleData> = new Vector.<TriangleData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorChannelData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<ChannelData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<ChannelData> = new Vector.<ChannelData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorJointEntryData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<JointEntryData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<JointEntryData> = new Vector.<JointEntryData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorDeltaEntryData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<DeltaEntryData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<DeltaEntryData> = new Vector.<DeltaEntryData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function deserializeVectorFrameData(input:ByteArray, version:uint, deserializeFn:Function):Vector.<FrameData>
		{
			var count:uint = input.readUnsignedInt();
			if (count == 0) return null;
			else
			{
				var result:Vector.<FrameData> = new Vector.<FrameData>();
				for (var i:uint=0; i<count; ++i) result[i] = deserializeFn(input, version);
				return result;
			}
		}
		private static function serializeVector(output:ByteArray, version:uint, vector:*, serializeFn:Function):void // serializeFn<ByteArray, *>
		{
			if (vector == null)
				output.writeUnsignedInt(0);
			else
			{
				output.writeUnsignedInt(vector.length);
				for (var i:uint=0; i<vector.length; ++i) 
					serializeFn(output, vector[i], version);	
			}
		}

		// STATIC OPERATIONS ///////////////////////////////////////////////////////////////
		
		// MISC ///////////////////////////////////////////////////////////////////
		public static function UV_create(u:Number, v:Number):UVData { var uv:UVData = new UVData(); uv.u = u; uv.v = v; return uv; }
		public static function UV_assign(uv:UVData, u:Number=0, v:Number=0):void { uv.u = u; uv.v = v; }
		public static const e11:Number = 0; public static const e21:Number = 1; public static const e31:Number = 2; public static const e41:Number = 3;
		public static const e12:Number = 4; public static const e22:Number = 5; public static const e32:Number = 6; public static const e42:Number = 7;
		public static const e13:Number = 8; public static const e23:Number = 9; public static const e33:Number = 10; public static const e43:Number = 11;
		public static const e14:Number = 12; public static const e24:Number = 13; public static const e34:Number = 14; public static const e44:Number = 15;
		public static function Matrix_create(_11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
									  _21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
									  _31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
									  _41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false):MatrixData
		{
			var mat:MatrixData = new MatrixData();
			mat.n11 = _11, mat.n12 = _12, mat.n13 = _13, mat.n14 = _14,
			mat.n21 = _21, mat.n22 = _22, mat.n23 = _23, mat.n24 = _24,
			mat.n31 = _31, mat.n32 = _32, mat.n33 = _33, mat.n34 = _34,
			mat.n41 = _41, mat.n42 = _42, mat.n43 = _43, mat.n44 = _44;
			mat.flags = isIdentity?1:0;
			return mat;
		}
		public static function Matrix_assign(mat:MatrixData, src:MatrixData):void
		{
			if ((src.flags>0) && (mat.flags>0))
				return;
			
			mat.n11 = src.n11; mat.n12 = src.n12; mat.n13 = src.n13; mat.n14 = src.n14;
			mat.n21 = src.n21; mat.n22 = src.n22; mat.n23 = src.n23; mat.n24 = src.n24;
			mat.n31 = src.n31; mat.n32 = src.n32; mat.n33 = src.n33; mat.n34 = src.n34;
			mat.n41 = src.n41; mat.n42 = src.n42; mat.n43 = src.n43; mat.n44 = src.n44;
			mat.flags = src.flags;
		}
		public static function Matrix_assignFromElements(mat:MatrixData,
												  _11:Number=0, _12:Number=0, _13:Number=0, _14:Number=0,
												  _21:Number=0, _22:Number=0, _23:Number=0, _24:Number=0,
												  _31:Number=0, _32:Number=0, _33:Number=0, _34:Number=0,
												  _41:Number=0, _42:Number=0, _43:Number=0, _44:Number=0, isIdentity:Boolean=false):void
		{
			mat.n11 = _11, mat.n12 = _12, mat.n13 = _13, mat.n14 = _14,
			mat.n21 = _21, mat.n22 = _22, mat.n23 = _23, mat.n24 = _24,
			mat.n31 = _31, mat.n32 = _32, mat.n33 = _33, mat.n34 = _34,
			mat.n41 = _41, mat.n42 = _42, mat.n43 = _43, mat.n44 = _44;
			mat.flags = isIdentity?1:0;
		}
		public static function Matrix_identity(mat:MatrixData):void
		{
			mat.n11 = 1; mat.n12 = 0; mat.n13 = 0; mat.n14 = 0;
			mat.n21 = 0; mat.n22 = 1; mat.n23 = 0; mat.n24 = 0;
			mat.n31 = 0; mat.n32 = 0; mat.n33 = 1; mat.n34 = 0;
			mat.flags = 1; 
		}
		public static function Matrix_createFromArray(array:Array):MatrixData
		{
			var a:Array = [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1];
			for (var i:int=0; i<Math.min(array.length,a.length); ++i)
				a[i] = array[i];
			
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				a[ 0], a[ 1], a[ 2], a[ 3],
				a[ 4], a[ 5], a[ 6], a[ 7],
				a[ 8], a[ 9], a[10], a[11],
				a[12], a[13], a[14], a[15]);
			return result;
		}
		public static function Matrix_translateBy(mat:MatrixData, x:Number, y:Number, z:Number):void
		{
			mat.n14 += x;
			mat.n24 += y;
			mat.n34 += z;
			mat.flags = 0;
		}
		public static function Matrix_translateTo(mat:MatrixData, x:Number, y:Number, z:Number):void
		{
			mat.n14 = x;
			mat.n24 = y;
			mat.n34 = z;
			mat.flags = 0;
		}
		public static function Matrix_transform(mat:MatrixData, position:Vector3D, degrees:Vector3D, scale:Vector3D):void
		{
			Matrix_transformInRadians(mat, position, new Vector3D(degrees.x*Maff.DEG_TO_RAD, degrees.y*Maff.DEG_TO_RAD, degrees.z*Maff.DEG_TO_RAD), scale);
		}
		public static function Matrix_transformInRadians(mat:MatrixData, position:Vector3D, orientation:Vector3D, scale:Vector3D):void
		{
			// translate
			mat.n14 = position.x;
			mat.n24 = position.y;
			mat.n34 = position.z;
			
			// rotate
			var cx:Number = Math.cos(orientation.x);
			var sx:Number = Math.sin(orientation.x);
			var cy:Number = Math.cos(orientation.y);
			var sy:Number = Math.sin(orientation.y);
			var cz:Number = Math.cos(orientation.z);
			var sz:Number = Math.sin(orientation.z);
			
			mat.n11 = cy*cz;	
			mat.n12 = cx*sz-sx*sy*cz;	
			mat.n13 = cx*sy*cz+sx*sz;	
			mat.n21 = -cy*sz;
			mat.n22 = sx*sy*sz+cx*cz;	
			mat.n23 = sx*cz-cx*sy*sz;	
			mat.n31 = -sy;
			mat.n32 = -sx*cy;				
			mat.n33 = cx*cy;
			
			// scale	
			if (scale.x != 1)
			{ 
				mat.n11 *= scale.x;	
				mat.n21 *= scale.x;
				mat.n31 *= scale.x;
			}
			if (scale.y != 1)
			{
				mat.n12 *= scale.y;	
				mat.n22 *= scale.y;	
				mat.n32 *= scale.y;				
			}
			if (scale.z != 1)
			{
				mat.n13 *= scale.z;	
				mat.n23 *= scale.z;	
				mat.n33 *= scale.z;
			}
			mat.flags = 0;
		}
		public static function Matrix_createTranslate(x:Number, y:Number, z:Number):MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result, 1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, z, 0, 0, 0, 1);
			return result;
		}
		public static function Matrix_createTransformMatrix(x:Number, y:Number, z:Number, degX:Number, degY:Number, degZ:Number, sclX:Number, sclY:Number, sclZ:Number):MatrixData
		{
			var result:MatrixData = Matrix_createRotate(degX, degY, degZ);
			Matrix_mulMatMat(result, result, Matrix_createScale(sclX, sclY, sclZ));
			result.n14 = x; result.n24 = y; result.n34 = z;
			return result;
		}
		public static function Matrix_createScale(xScale:Number, yScale:Number, zScale:Number):MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result, xScale, 0, 0, 0, 0, yScale, 0, 0, 0, 0, zScale, 0, 0, 0, 0, 1);
			return result;
		}
		public static function Matrix_createRotateAngleAxis(x:Number, y:Number, z:Number, degrees:Number):MatrixData
		{
			return Matrix_createRotateAngleAxisWithRadians(x, y, z, Maff.DEG_TO_RAD * degrees);
		}
		public static function Matrix_createRotateAngleAxisWithRadians(x:Number, y:Number, z:Number, radians:Number):MatrixData
		{
			var c:Number = Math.cos(radians);
			var s:Number = Math.sin(radians);
			var scos:Number	= 1-c;
			
			var sxy:Number = x*y*scos;
			var syz:Number = y*z*scos;
			var sxz:Number = x*z*scos;
			var sz:Number = s*z;
			var sy:Number = s*y;
			var sx:Number = s*x;
			
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				c+x*x*scos,	-sz+sxy,	sy+sxz,		0,
				sz+sxy, 	c+y*y*scos,	-sx+syz, 	0,	
				-sy+sxz,	sx+syz,		c+z*z*scos,	0,
				0, 			0, 			0, 			1);
			return result;
		}
		public static function Matrix_createRotateVecWithRadians(radians:Vector3D):MatrixData
		{
			return Matrix_createRotateWithRadians(radians.x, radians.y, radians.z);
		}
		public static function Matrix_createRotateWithRadians(radiansX:Number, radiansY:Number, radiansZ:Number):MatrixData
		{
			var pitch:Number = radiansX;
			var yaw:Number = radiansY;
			var roll:Number = radiansZ;
			
			var cx:Number = Math.cos(pitch);
			var sx:Number = Math.sin(pitch);
			var cy:Number = Math.cos(yaw);
			var sy:Number = Math.sin(yaw);
			var cz:Number = Math.cos(roll);
			var sz:Number = Math.sin(roll);
			
			//rx->ry->rz
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
			return result;
		}
		
		public static function Matrix_createViewport(x:Number, y:Number, width:Number, height:Number):MatrixData
		{
			var hw:Number = width * 0.5;
			var hh:Number = height * 0.5;
			var result:MatrixData = new MatrixData();
			DataUtil.Matrix_assignFromElements(result,
				hw,  0, 0, x+hw,
				 0, hh, 0, y+hh,
				 0,  0, 0, 0,
				 0,  0, 0, 1
				);
			return result;
		}
		public static function Matrix_createOrthographic(width:Number, height:Number, nearClip:Number, farClip:Number):MatrixData
		{
			var result:MatrixData = new MatrixData();
			DataUtil.Matrix_assignFromElements(result,
				-2.0/width, 0.0, 			0.0, 						0.0,
				0.0, 		-2.0/height, 	0.0, 						0.0,
				0.0, 		0.0, 			-1.0/(farClip - nearClip), 	nearClip/(nearClip - farClip),
				0.0, 		0.0, 			0.0, 						1.0);
			return result;
		}
		public static function Matrix_createPerspective(halfFieldOfViewYDegrees:Number, widthOverHeightRatio:Number, nearClip:Number, farClip:Number):MatrixData
		{
			var halfHeight:Number = nearClip * Math.tan(halfFieldOfViewYDegrees * Maff.DEG_TO_RAD);
			var halfWidth:Number = halfHeight * widthOverHeightRatio;
			return Matrix_createFrustum(-halfWidth, halfWidth, -halfHeight, halfHeight, nearClip, farClip);
		}
		public static function Matrix_createFrustum(left:Number, right:Number, bottom:Number, top:Number, front:Number, back:Number):MatrixData
		{
			var invWidth:Number = 1/(right-left);
			var invHeight:Number = 1/(top-bottom);
			var invDepth:Number = 1/(back-front);
			
			/*
			return new MatrixData(
			2*front*invWidth,	0,								(right+left)*invWidth,		0,
			0,						2*front*invHeight,			(top+bottom)*invHeight,		0,
			0,						0,							(back+front)*invDepth,		2*back*front*invDepth,
			0,						0,							-1,							0);
			*/
			var result:MatrixData = new MatrixData();
			DataUtil.Matrix_assignFromElements(result,
				2*front*invWidth,	0,								(right+left)*invWidth,		0,
				0,						2*front*invHeight,			(top+bottom)*invHeight,		0,
				0,						0,							-(back+front)*invDepth,		2*back*front*invDepth,
				0,						0,							-1,							0);
			return result;
		}
		public static function Matrix_createRotateVec(degrees:Vector3D):MatrixData
		{
			return Matrix_createRotate(degrees.x, degrees.y, degrees.z);
		}
		public static function Matrix_createRotate(degreesX:Number, degreesY:Number, degreesZ:Number):MatrixData
		{
			var pitch:Number = degreesX * Maff.DEG_TO_RAD;
			var yaw:Number = degreesY * Maff.DEG_TO_RAD;
			var roll:Number = degreesZ * Maff.DEG_TO_RAD;
			
			var cx:Number = Math.cos(pitch);
			var sx:Number = Math.sin(pitch);
			var cy:Number = Math.cos(yaw);
			var sy:Number = Math.sin(yaw);
			var cz:Number = Math.cos(roll);
			var sz:Number = Math.sin(roll);
			
			//rx->ry->rz
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result,
				cy*cz,	cx*sz-sx*sy*cz,	cx*sy*cz+sx*sz,	0,
				-cy*sz,	sx*sy*sz+cx*cz,	sx*cz-cx*sy*sz,	0,
				-sy,	-sx*cy,			cx*cy,			0,
				0,			0,			0,				1);
			return result;
		}
		public static function Matrix_composeTransform(posX:Number, posY:Number, posZ:Number, degX:Number, degY:Number, degZ:Number, sclX:Number, sclY:Number, sclZ:Number):MatrixData
		{
			return Matrix_composeTransformWithRadians
			(
				posX, posY, posZ, 
				degX*Maff.DEG_TO_RAD, degY*Maff.DEG_TO_RAD, degZ*Maff.DEG_TO_RAD, 
				sclX, sclY, sclZ
			);
		}
		public static function Matrix_composeTransformWithRadians(posX:Number, posY:Number, posZ:Number, radX:Number, radY:Number, radZ:Number, sclX:Number, sclY:Number, sclZ:Number):MatrixData
		{
			var mat:MatrixData = Matrix_createIdentity();
			
			// translate
			mat.n14 = posX;
			mat.n24 = posY;
			mat.n34 = posZ;
			
			// rotate
			var cx:Number = Math.cos(radX);
			var sx:Number = Math.sin(radX);
			var cy:Number = Math.cos(radY);
			var sy:Number = Math.sin(radY);
			var cz:Number = Math.cos(radZ);
			var sz:Number = Math.sin(radZ);
			
			mat.n11 = cy*cz;	
			mat.n12 = cx*sz-sx*sy*cz;	
			mat.n13 = cx*sy*cz+sx*sz;	
			mat.n21 = -cy*sz;
			mat.n22 = sx*sy*sz+cx*cz;	
			mat.n23 = sx*cz-cx*sy*sz;	
			mat.n31 = -sy;
			mat.n32 = -sx*cy;				
			mat.n33 = cx*cy;
			
			// scale	
			if (sclX != 1)
			{ 
				mat.n11 *= sclX;	
				mat.n21 *= sclX;
				mat.n31 *= sclX;
			}
			if (sclY != 1)
			{
				mat.n12 *= sclY;	
				mat.n22 *= sclY;	
				mat.n32 *= sclY;				
			}
			if (sclZ != 1)
			{
				mat.n13 *= sclZ;	
				mat.n23 *= sclZ;	
				mat.n33 *= sclZ;
			}
			mat.flags = 0;
			
			return mat;
		}
		public static function Matrix_decomposeTransform(transform:MatrixData, position:Vector3D, orientation:Vector3D, scale:Vector3D):void
		{
			Matrix_decomposeElementsToRadians(
				transform.n11, transform.n12, transform.n13, transform.n14,
				transform.n21, transform.n22, transform.n23, transform.n24,
				transform.n31, transform.n32, transform.n33, transform.n34, 
				position, orientation, scale);
			
			if (orientation != null)
			{
				orientation.x *= Maff.RAD_TO_DEG;
				orientation.y *= Maff.RAD_TO_DEG;
				orientation.z *= Maff.RAD_TO_DEG;
			}
		}
		public static function Matrix_decomposeTransformToRadians(transform:MatrixData, position:Vector3D, orientationRadians:Vector3D, scale:Vector3D):void
		{
			if (transform.flags > 0)
			{
				if (position != null)
					Maff.Vector3D_assign(position, 0, 0, 0);
				if (orientationRadians != null)
					Maff.Vector3D_assign(orientationRadians, 0, 0, 0);
				if (scale != null)
					Maff.Vector3D_assign(scale, 1, 1, 1);
			}
			else
			{
				Matrix_decomposeElementsToRadians(
					transform.n11, transform.n12, transform.n13, transform.n14,
					transform.n21, transform.n22, transform.n23, transform.n24,
					transform.n31, transform.n32, transform.n33, transform.n34,
					position, orientationRadians, scale);
			}
		}
		public static function Matrix_decomposeElements(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Vector3D, orientation:Vector3D, scale:Vector3D):void
		{
			Matrix_decomposeElementsToRadians(
				n11, n12, n13, n14,
				n21, n22, n23, n24,
				n31, n32, n33, n34,
				position, orientation, scale);
			
			orientation.x *= Maff.RAD_TO_DEG;
			orientation.y *= Maff.RAD_TO_DEG;
			orientation.z *= Maff.RAD_TO_DEG;
		}
		public static function Matrix_decomposeElementsToRadians(
			n11:Number, n12:Number, n13:Number, n14:Number,
			n21:Number, n22:Number, n23:Number, n24:Number,
			n31:Number, n32:Number, n33:Number, n34:Number,
			position:Vector3D, orientationRadians:Vector3D, scale:Vector3D):void
		{
			var sx:Number = Math.sqrt(n11*n11 + n21*n21 + n31*n31); 
			var sy:Number = Math.sqrt(n12*n12 + n22*n22 + n32*n32);
			var sz:Number = Math.sqrt(n13*n13 + n23*n23 + n33*n33);
			
			if (scale != null)
			{
				scale.x = sx;
				scale.y = sy;
				scale.z = sz;
			}
			
			if (orientationRadians != null)
			{
				var iX:Number = 1 / sx;
				var iY:Number = 1 / sy;
				
				n31 *= iX;
				if (n31 > 0.998)
				{
					n12 *= iY;
					n22 *= iY;
					
					orientationRadians.x = 0;
					orientationRadians.y = -Maff.HALF_PI;
					orientationRadians.z = Math.atan2(n12, n22);
				}
				else if (n31 < -0.998)
				{
					n12 *= iY;
					n22 *= iY;
					
					orientationRadians.x = 0;
					orientationRadians.y = Maff.HALF_PI;
					orientationRadians.z = Math.atan2(n12, n22);
				}
				else
				{
					var iZ:Number = 1 / sz;
					
					n11 *= iX;
					n21 *= iX;
					n32 *= iY;
					n33 *= iZ;
					
					orientationRadians.x = Math.atan2(-n32, n33);
					orientationRadians.y = Math.asin(-n31);
					orientationRadians.z = Math.atan2(-n21, n11); 			
				}
			}
			
			if (position != null)
			{
				position.x = n14;
				position.y = n24;
				position.z = n34;
			}
			
			/*
			// ouch
			var sx:Number = Math.sqrt(n11*n11 + n12*n12 + n13*n13); 
			var sy:Number = Math.sqrt(n21*n21 + n22*n22 + n23*n23);
			var sz:Number = Math.sqrt(n31*n31 + n32*n32 + n33*n33);
			
			if (scale != null)
			{
				scale.x = sx;
				scale.y = sy;
				scale.z = sz;
			}
			
			if (orientationRadians != null)
			{
				if (sx==0 && sy==0 && sz==0)
				{
					orientationRadians.x = 0;
					orientationRadians.y = 0;
					orientationRadians.z = 0;
				}
				else
				{
					var invSx:Number = 1.0 / sx;
					var invSy:Number = 1.0 / sy;
					var invSz:Number = 1.0 / sz;
					
					var e11:Number = n11 * invSx;
					var e12:Number = n12 * invSx;
					var e13:Number = n13 * invSx;
					var e21:Number = n21 * invSy;
					var e22:Number = n22 * invSy;
					var e23:Number = n23 * invSy;
					var e31:Number = n31 * invSz;
					var e32:Number = n32 * invSz;
					var e33:Number = n33 * invSz;
					
					var cy:Number = Math.sqrt(e22*e22 + e12*e12);
					var rx:Number = Math.atan2(-e32, cy);
					var ry:Number, rz:Number;
					if (cy > 16*Number.MIN_VALUE)
					{
						ry = Math.atan2(e31, e33);
						rz = Math.atan2(e12, e22);
					}
					else
					{
						ry = Math.atan2(-e13, e11);
						rz = 0.0;
					}
					orientationRadians.x = rx;
					orientationRadians.y = ry;
					orientationRadians.z = rz;
				}
			}
			
			if (position != null)
			{
				position.x = n14;
				position.y = n24;
				position.z = n34;
			}
			*/
		}
		public static function Matrix_transpose(mat:MatrixData):void
		{
			if (mat.flags == 0)
			{
				var tmp:Number;
				tmp = mat.n21; mat.n21 = mat.n12; mat.n12 = tmp;
				tmp = mat.n31; mat.n31 = mat.n13; mat.n13 = tmp;
				tmp = mat.n32; mat.n32 = mat.n23; mat.n23 = tmp;
				//tmp = n41; n41 = n14; n14 = tmp;
				//tmp = n42; n42 = n24; n24 = tmp;
				//tmp = n43; n43 = n34; n34 = tmp;
			}
		}
		private static var rawDataTmp:Vector.<Number> = new Vector.<Number>(16, true);
		public function Matrix_rawData(mat:MatrixData):Vector.<Number>
		{
			rawDataTmp[e11] = mat.n11;
			rawDataTmp[e21] = mat.n21;
			rawDataTmp[e31] = mat.n31;
			rawDataTmp[e41] = 0;
			rawDataTmp[e12] = mat.n12;
			rawDataTmp[e22] = mat.n22;
			rawDataTmp[e32] = mat.n32;
			rawDataTmp[e42] = 0;
			rawDataTmp[e13] = mat.n13;
			rawDataTmp[e23] = mat.n23;
			rawDataTmp[e33] = mat.n33;
			rawDataTmp[e43] = 0;
			rawDataTmp[e14] = mat.n14;
			rawDataTmp[e24] = mat.n24;
			rawDataTmp[e34] = mat.n34;
			rawDataTmp[e44] = 1;
			return rawDataTmp;
		}
		public static const Matrix_STATIC_IDENTITY:MatrixData = Matrix_createIdentity();
		public static function Matrix_createIdentity():MatrixData
		{
			var result:MatrixData = new MatrixData();
			Matrix_assignFromElements(result, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, true);
			return result;
		}
		public static function Matrix_append(mat:MatrixData, m:MatrixData):void
		{
			if (m.flags > 0)
				return;
			else if (mat.flags > 0)
				Matrix_assign(mat, m);
			else
			{
				var a:MatrixData = mat;
				var m11:Number = a.n11 * m.n11 + a.n12 * m.n21 + a.n13 * m.n31 + a.n14 * m.n41;
				var m12:Number = a.n11 * m.n12 + a.n12 * m.n22 + a.n13 * m.n32 + a.n14 * m.n42;
				var m13:Number = a.n11 * m.n13 + a.n12 * m.n23 + a.n13 * m.n33 + a.n14 * m.n43;
				var m14:Number = a.n11 * m.n14 + a.n12 * m.n24 + a.n13 * m.n34 + a.n14 * m.n44;
				var m21:Number = a.n21 * m.n11 + a.n22 * m.n21 + a.n23 * m.n31 + a.n24 * m.n41;
				var m22:Number = a.n21 * m.n12 + a.n22 * m.n22 + a.n23 * m.n32 + a.n24 * m.n42;
				var m23:Number = a.n21 * m.n13 + a.n22 * m.n23 + a.n23 * m.n33 + a.n24 * m.n43;
				var m24:Number = a.n21 * m.n14 + a.n22 * m.n24 + a.n23 * m.n34 + a.n24 * m.n44;
				var m31:Number = a.n31 * m.n11 + a.n32 * m.n21 + a.n33 * m.n31 + a.n34 * m.n41;
				var m32:Number = a.n31 * m.n12 + a.n32 * m.n22 + a.n33 * m.n32 + a.n34 * m.n42;
				var m33:Number = a.n31 * m.n13 + a.n32 * m.n23 + a.n33 * m.n33 + a.n34 * m.n43;
				var m34:Number = a.n31 * m.n14 + a.n32 * m.n24 + a.n33 * m.n34 + a.n34 * m.n44;
				var m41:Number = a.n41 * m.n11 + a.n42 * m.n21 + a.n43 * m.n31 + a.n44 * m.n41;
				var m42:Number = a.n41 * m.n12 + a.n42 * m.n22 + a.n43 * m.n32 + a.n44 * m.n42;
				var m43:Number = a.n41 * m.n13 + a.n42 * m.n23 + a.n43 * m.n33 + a.n44 * m.n43;
				var m44:Number = a.n41 * m.n14 + a.n42 * m.n24 + a.n43 * m.n34 + a.n44 * m.n44;
				
				mat.n11 = m11; mat.n12 = m12; mat.n13 = m13; mat.n14 = m14;
				mat.n21 = m21; mat.n22 = m22; mat.n23 = m23; mat.n24 = m24;
				mat.n31 = m31; mat.n32 = m32; mat.n33 = m33; mat.n34 = m34;
				mat.n41 = m41; mat.n42 = m42; mat.n43 = m43; mat.n44 = m44;
				
				mat.flags = 0;
			}
		}
		public static function Matrix_prepend(mat:MatrixData, a:MatrixData):void
		{
			if (a.flags > 0)
				return;
			else if (mat.flags > 0)
				Matrix_assign(mat, a);
			else
			{
				var m:MatrixData = mat;
				var m11:Number = a.n11 * m.n11 + a.n12 * m.n21 + a.n13 * m.n31 + a.n14 * m.n41;
				var m12:Number = a.n11 * m.n12 + a.n12 * m.n22 + a.n13 * m.n32 + a.n14 * m.n42;
				var m13:Number = a.n11 * m.n13 + a.n12 * m.n23 + a.n13 * m.n33 + a.n14 * m.n43;
				var m14:Number = a.n11 * m.n14 + a.n12 * m.n24 + a.n13 * m.n34 + a.n14 * m.n44;
				var m21:Number = a.n21 * m.n11 + a.n22 * m.n21 + a.n23 * m.n31 + a.n24 * m.n41;
				var m22:Number = a.n21 * m.n12 + a.n22 * m.n22 + a.n23 * m.n32 + a.n24 * m.n42;
				var m23:Number = a.n21 * m.n13 + a.n22 * m.n23 + a.n23 * m.n33 + a.n24 * m.n43;
				var m24:Number = a.n21 * m.n14 + a.n22 * m.n24 + a.n23 * m.n34 + a.n24 * m.n44;
				var m31:Number = a.n31 * m.n11 + a.n32 * m.n21 + a.n33 * m.n31 + a.n34 * m.n41;
				var m32:Number = a.n31 * m.n12 + a.n32 * m.n22 + a.n33 * m.n32 + a.n34 * m.n42;
				var m33:Number = a.n31 * m.n13 + a.n32 * m.n23 + a.n33 * m.n33 + a.n34 * m.n43;
				var m34:Number = a.n31 * m.n14 + a.n32 * m.n24 + a.n33 * m.n34 + a.n34 * m.n44;
				var m41:Number = a.n41 * m.n11 + a.n42 * m.n21 + a.n43 * m.n31 + a.n44 * m.n41;
				var m42:Number = a.n41 * m.n12 + a.n42 * m.n22 + a.n43 * m.n32 + a.n44 * m.n42;
				var m43:Number = a.n41 * m.n13 + a.n42 * m.n23 + a.n43 * m.n33 + a.n44 * m.n43;
				var m44:Number = a.n41 * m.n14 + a.n42 * m.n24 + a.n43 * m.n34 + a.n44 * m.n44;
				
				mat.n11 = m11; mat.n12 = m12; mat.n13 = m13; mat.n14 = m14;
				mat.n21 = m21; mat.n22 = m22; mat.n23 = m23; mat.n24 = m24;
				mat.n31 = m31; mat.n32 = m32; mat.n33 = m33; mat.n34 = m34;
				mat.n41 = m41; mat.n42 = m42; mat.n43 = m43; mat.n44 = m44;
				
				mat.flags = 0;
			}
		}
		public static function Matrix_mulMat(mat:MatrixData, b:MatrixData):void
		{
			if (b.flags > 0)
				return;
			else if (mat.flags > 0)
				Matrix_assign(mat, b);
			else
			{
				var a11:Number = mat.n11; var b11:Number = b.n11;
				var a21:Number = mat.n21; var b21:Number = b.n21;
				var a31:Number = mat.n31; var b31:Number = b.n31;
				
				var a12:Number = mat.n12; var b12:Number = b.n12;
				var a22:Number = mat.n22; var b22:Number = b.n22;
				var a32:Number = mat.n32; var b32:Number = b.n32;
				
				var a13:Number = mat.n13; var b13:Number = b.n13;
				var a23:Number = mat.n23; var b23:Number = b.n23;
				var a33:Number = mat.n33; var b33:Number = b.n33;
				
				var a14:Number = mat.n14; var b14:Number = b.n14;
				var a24:Number = mat.n24; var b24:Number = b.n24;
				var a34:Number = mat.n34; var b34:Number = b.n34;
				
				mat.n11 = a11 * b11 + a12 * b21 + a13 * b31;
				mat.n12 = a11 * b12 + a12 * b22 + a13 * b32;
				mat.n13 = a11 * b13 + a12 * b23 + a13 * b33;
				mat.n14 = a11 * b14 + a12 * b24 + a13 * b34 + a14;
				
				mat.n21 = a21 * b11 + a22 * b21 + a23 * b31;
				mat.n22 = a21 * b12 + a22 * b22 + a23 * b32;
				mat.n23 = a21 * b13 + a22 * b23 + a23 * b33;
				mat.n24 = a21 * b14 + a22 * b24 + a23 * b34 + a24;
				
				mat.n31 = a31 * b11 + a32 * b21 + a33 * b31;
				mat.n32 = a31 * b12 + a32 * b22 + a33 * b32;
				mat.n33 = a31 * b13 + a32 * b23 + a33 * b33;
				mat.n34 = a31 * b14 + a32 * b24 + a33 * b34 + a34;
				
				mat.flags = 0;
			}
		}
		
		public static function Matrix_tryCalcOrientationFromAimAndUp(aim:Vector3D, up:Vector3D):Vector3D
		{
			var result:Vector3D = Matrix_tryCalcOrientationFromAimAndUpInRadians(aim, up);
			result.scaleBy(Maff.RAD_TO_DEG);
			return result;
		}
		public static function Matrix_tryCalcOrientationFromAimAndUpInRadians(aim:Vector3D, up:Vector3D):Vector3D
		{
			//var axisZ:Vector3D = at.subtract(this.position());
			var axisZ:Vector3D = aim;
			if (axisZ.x == 0 && axisZ.y == 0 && axisZ.z == 0)
				return null;
			axisZ.normalize();
			var axisX:Vector3D = up.crossProduct(axisZ);
			if (axisX.x == 0 && axisX.y == 0 && axisX.z == 0)
				return null;
			axisX.normalize();
			var axisY:Vector3D = axisZ.crossProduct(axisX);
			if (axisY.x == 0 && axisY.y == 0 && axisY.z == 0)
				return null;
			axisY.normalize();
			
			var rx:Number = -Math.atan2(axisY.z, axisZ.z);
			var ry:Number = -Math.asin(axisX.z);
			var rz:Number = -Math.atan2(axisX.y, axisX.x);
			return new Vector3D(rx, ry, rz);
		}
		
		public static function Matrix_inverseFull(mat:MatrixData):MatrixData
		{
			if (mat.flags > 0)
				return Matrix_clone(mat);
			else
			{
				var n11:Number = mat.n11; var n12:Number = mat.n12; var n13:Number = mat.n13; var n14:Number = mat.n14;
				var n21:Number = mat.n21; var n22:Number = mat.n22; var n23:Number = mat.n23; var n24:Number = mat.n24;
				var n31:Number = mat.n31; var n32:Number = mat.n32; var n33:Number = mat.n33; var n34:Number = mat.n34;
				var n41:Number = mat.n41; var n42:Number = mat.n42; var n43:Number = mat.n43; var n44:Number = mat.n44;
				
				var det:Number = n14 * n23 * n32 * n41 - n13 * n24 * n32 * n41 - n14 * n22 * n33 * n41 + n12 * n24 * n33 * n41 +
					n13 * n22 * n34 * n41 - n12 * n23 * n34 * n41 - n14 * n23 * n31 * n42 + n13 * n24 * n31 * n42 +
					n14 * n21 * n33 * n42 - n11 * n24 * n33 * n42 - n13 * n21 * n34 * n42 + n11 * n23 * n34 * n42 +
					n14 * n22 * n31 * n43 - n12 * n24 * n31 * n43 - n14 * n21 * n32 * n43 + n11 * n24 * n32 * n43 +
					n12 * n21 * n34 * n43 - n11 * n22 * n34 * n43 - n13 * n22 * n31 * n44 + n12 * n23 * n31 * n44 +
					n13 * n21 * n32 * n44 - n11 * n23 * n32 * n44 - n12 * n21 * n33 * n44 + n11 * n22 * n33 * n44;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				var result:MatrixData = new MatrixData();
				Matrix_assignFromElements(result,
					(n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44) * invDet,
					(n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44) * invDet,
					(n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44) * invDet,
					(n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34) * invDet,
					(n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * invDet,
					(n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * invDet,
					(n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * invDet,
					(n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * invDet,
					(n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * invDet,
					(n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * invDet,
					(n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * invDet,
					(n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * invDet,
					(n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * invDet,
					(n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * invDet,
					(n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * invDet,
					(n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * invDet);
				return result;
			}
		}
		public static function Matrix_inverse(result:MatrixData, mat:MatrixData):void
		{
			if (mat.flags > 0)
				Matrix_assign(result, mat);
			else
			{
				var det:Number = 
					(mat.n11 * mat.n22 - mat.n21 * mat.n12) * mat.n33 - 
					(mat.n11 * mat.n32 - mat.n31 * mat.n12) * mat.n23 +
					(mat.n21 * mat.n32 - mat.n31 * mat.n22) * mat.n13;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				var m11:Number = mat.n11; var m21:Number = mat.n21; var m31:Number = mat.n31;
				var m12:Number = mat.n12; var m22:Number = mat.n22; var m32:Number = mat.n32;
				var m13:Number = mat.n13; var m23:Number = mat.n23; var m33:Number = mat.n33;
				var m14:Number = mat.n14; var m24:Number = mat.n24; var m34:Number = mat.n34;
				
				Matrix_assignFromElements(result,
					 invDet * ( m22 * m33 - m32 * m23 ),
					-invDet * ( m12 * m33 - m32 * m13 ),
					 invDet * ( m12 * m23 - m22 * m13 ),
					-invDet * ( m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14) ),
					-invDet * ( m21 * m33 - m31 * m23 ),
					 invDet * ( m11 * m33 - m31 * m13 ),
					-invDet * ( m11 * m23 - m21 * m13 ),
					 invDet * ( m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14) ),
					 invDet * ( m21 * m32 - m31 * m22 ),
					-invDet * ( m11 * m32 - m31 * m12 ),
					 invDet * ( m11 * m22 - m21 * m12 ),
					-invDet * ( m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14) ),
					0, 0, 0, 1);
			}
		}
		public static function Matrix_inverseCopy(mat:MatrixData):MatrixData
		{
			if (mat.flags > 0)
				return Matrix_clone(mat);
			else
			{
				var det:Number = 
					(mat.n11 * mat.n22 - mat.n21 * mat.n12) * mat.n33 - 
					(mat.n11 * mat.n32 - mat.n31 * mat.n12) * mat.n23 +
					(mat.n21 * mat.n32 - mat.n31 * mat.n22) * mat.n13;
				var invDet:Number = det == 1 ? 1 : 1 / det;
				
				var m11:Number = mat.n11; var m21:Number = mat.n21; var m31:Number = mat.n31;
				var m12:Number = mat.n12; var m22:Number = mat.n22; var m32:Number = mat.n32;
				var m13:Number = mat.n13; var m23:Number = mat.n23; var m33:Number = mat.n33;
				var m14:Number = mat.n14; var m24:Number = mat.n24; var m34:Number = mat.n34;
				
				var result:MatrixData = new MatrixData();
				Matrix_assignFromElements(result,
					 invDet * ( m22 * m33 - m32 * m23 ),
					-invDet * ( m12 * m33 - m32 * m13 ),
					 invDet * ( m12 * m23 - m22 * m13 ),
					-invDet * ( m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14) ),
					-invDet * ( m21 * m33 - m31 * m23 ),
					 invDet * ( m11 * m33 - m31 * m13 ),
					-invDet * ( m11 * m23 - m21 * m13 ),
					 invDet * ( m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14) ),
					 invDet * ( m21 * m32 - m31 * m22 ),
					-invDet * ( m11 * m32 - m31 * m12 ),
					 invDet * ( m11 * m22 - m21 * m12 ),
					-invDet * ( m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14) ),
					0, 0, 0, 1);
				return result;
			}
		}
		public static function Matrix_mulMatMat(result:MatrixData, a:MatrixData, b:MatrixData):void
		{
			if ((a.flags>0) && (b.flags>0))
			{
				Matrix_assign(result, Matrix_STATIC_IDENTITY);
				result.flags = 1;
			}
			else if (a.flags > 0)
			{
				Matrix_assign(result, b);
				result.flags = 0;
			}
			else if (b.flags > 0)
			{
				Matrix_assign(result, a);
				result.flags = 0;
			}
			else
			{
				var n11:Number = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31;
				var n12:Number = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32;
				var n13:Number = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33;
				var n14:Number = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14;
				var n21:Number = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31;
				var n22:Number = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32;
				var n23:Number = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33;
				var n24:Number = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24;
				var n31:Number = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31;
				var n32:Number = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32;
				var n33:Number = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33;
				var n34:Number = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34;
				result.n11 = n11; result.n12 = n12; result.n13 = n13; result.n14 = n14;
				result.n21 = n21; result.n22 = n22; result.n23 = n23; result.n24 = n24;
				result.n31 = n31; result.n32 = n32; result.n33 = n33; result.n34 = n34;
				result.flags = 0;
			}
		}
		public static function Matrix_mulMatVec(m:MatrixData, v:Vector3D, result:Vector3D):void
		{
			if (m.flags == 0)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				result.x = x * m.n11 + y * m.n12 + z * m.n13 + m.n14;
				result.y = x * m.n21 + y * m.n22 + z * m.n23 + m.n24;
				result.z = x * m.n31 + y * m.n32 + z * m.n33 + m.n34;
			}
		}
		public static function Matrix_mulMatVecFull(m:MatrixData, v:Vector3D, result:Vector3D):void
		{
			if (m.flags == 0)
			{
				var x:Number = v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + v.w * m.n14;
				var y:Number = v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + v.w * m.n24;
				var z:Number = v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + v.w * m.n34;
				var w:Number = v.x * m.n41 + v.y * m.n42 + v.z * m.n43 + v.w * m.n44;
				result.x = x;
				result.y = y;
				result.z = z;
				result.w = w;
			}
		}
		/*
		public static function Matrix_vm(m:MatrixData, v:Vector3D):Number
		{
			if (m.flags == 0)
			{
				var x:Number = v.x;
				var y:Number = v.y;
				var z:Number = v.z;
				
				var invW:Number = 1.0 / (v.x*m.n41 + v.y*m.n42 + v.z*m.n43 + m.n44);
				v.x = (x * m.n11 + y * m.n12 + z * m.n13 + m.n14) * invW;
				v.y = (x * m.n21 + y * m.n22 + z * m.n23 + m.n24) * invW;
				v.z = (x * m.n31 + y * m.n32 + z * m.n33 + m.n34) * invW;
				v.w = 1;
				return invW;
			}
			return 1; 
		}
		*/
		public static function Matrix_mulMatVecWithWDivideFull(m:MatrixData, v:Vector3D, result:Vector3D):Number
		{
			if (m.flags == 0)
			{
				var w:Number = (v.x * m.n41 + v.y * m.n42 + v.z * m .n43 + v.w * m.n44);
				var invW:Number = 1.0 / w;
				var x:Number = (v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + v.w * m.n14) * invW;
				var y:Number = (v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + v.w * m.n24) * invW;
				var z:Number = (v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + v.w * m.n34) * invW;
				v.x = x;
				v.y = y;
				v.z = z;
				v.w = 1;
				return invW;
			}
			return 1;
		}
		public static function Matrix_mulMatVecCopy(m:MatrixData, v:Vector3D):Vector3D
		{
			if (m.flags > 0)
				return new Vector3D(v.x, v.y, v.z);
			else
				return new Vector3D(
					v.x * m.n11 + v.y * m.n12 + v.z * m.n13 + m.n14,
					v.x * m.n21 + v.y * m.n22 + v.z * m.n23 + m.n24,
					v.x * m.n31 + v.y * m.n32 + v.z * m.n33 + m.n34);
		}
		public static function Matrix_mulMatVecCopyWithWDivide(m:MatrixData, v:Vector3D):Vector3D
		{
			var invW:Number = 1.0 / (v.x*m.n41 + v.y*m.n42 + v.z*m.n43 + m.n44);
			return new Vector3D(
				(v.x*m.n11 + v.y*m.n12 + v.z*m.n13 + m.n14)*invW,
				(v.x*m.n21 + v.y*m.n22 + v.z*m.n23 + m.n24)*invW,
				(v.x*m.n31 + v.y*m.n32 + v.z*m.n33 + m.n34)*invW,
				invW);
		}
		public static function Matrix_mulMatMatFull(result:MatrixData, a:MatrixData, b:MatrixData):void
		{
			var n11:Number = a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31 + a.n14 * b.n41;
			var n12:Number = a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32 + a.n14 * b.n42;
			var n13:Number = a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33 + a.n14 * b.n43;
			var n14:Number = a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14 * b.n44;
			var n21:Number = a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31 + a.n24 * b.n41;
			var n22:Number = a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32 + a.n24 * b.n42;
			var n23:Number = a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33 + a.n24 * b.n43;
			var n24:Number = a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24 * b.n44;
			var n31:Number = a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31 + a.n34 * b.n41;
			var n32:Number = a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32 + a.n34 * b.n42;
			var n33:Number = a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33 + a.n34 * b.n43;
			var n34:Number = a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34 * b.n44;
			var n41:Number = a.n41 * b.n11 + a.n42 * b.n21 + a.n43 * b.n31 + a.n44 * b.n41;
			var n42:Number = a.n41 * b.n12 + a.n42 * b.n22 + a.n43 * b.n32 + a.n44 * b.n42;
			var n43:Number = a.n41 * b.n13 + a.n42 * b.n23 + a.n43 * b.n33 + a.n44 * b.n43;
			var n44:Number = a.n41 * b.n14 + a.n42 * b.n24 + a.n43 * b.n34 + a.n44 * b.n44;

			result.n11 = n11; result.n12 = n12; result.n13 = n13; result.n14 = n14; 
			result.n21 = n21; result.n22 = n22; result.n23 = n23; result.n24 = n24; 
			result.n31 = n31; result.n32 = n32; result.n33 = n33; result.n34 = n34; 
			result.n41 = n41; result.n42 = n42; result.n43 = n43; result.n44 = n44; 
		}
		public static function Matrix_mulMatMatCopy(a:MatrixData, b:MatrixData):MatrixData
		{
			if ((a.flags>0) && (b.flags>0))
				return Matrix_createIdentity();
			else if (a.flags > 0)
				return Matrix_clone(b);
			else if (b.flags > 0)
				return Matrix_clone(a);
			else
			{
				var result:MatrixData = new MatrixData();
				Matrix_assignFromElements(result,
					a.n11 * b.n11 + a.n12 * b.n21 + a.n13 * b.n31,
					a.n11 * b.n12 + a.n12 * b.n22 + a.n13 * b.n32,
					a.n11 * b.n13 + a.n12 * b.n23 + a.n13 * b.n33,
					a.n11 * b.n14 + a.n12 * b.n24 + a.n13 * b.n34 + a.n14,
					a.n21 * b.n11 + a.n22 * b.n21 + a.n23 * b.n31,
					a.n21 * b.n12 + a.n22 * b.n22 + a.n23 * b.n32,
					a.n21 * b.n13 + a.n22 * b.n23 + a.n23 * b.n33,
					a.n21 * b.n14 + a.n22 * b.n24 + a.n23 * b.n34 + a.n24,
					a.n31 * b.n11 + a.n32 * b.n21 + a.n33 * b.n31,
					a.n31 * b.n12 + a.n32 * b.n22 + a.n33 * b.n32,
					a.n31 * b.n13 + a.n32 * b.n23 + a.n33 * b.n33,
					a.n31 * b.n14 + a.n32 * b.n24 + a.n33 * b.n34 + a.n34,
					0, 0, 0, 1);
				return result;
			}
		}

		private static var arrayBuffer_:Array;
		public static function Matrix_toArray(mat:MatrixData):Array
		{
			if (arrayBuffer_ == null)
				arrayBuffer_ = [mat.n11, mat.n12, mat.n13, mat.n14, mat.n21, mat.n22, mat.n23, mat.n24, mat.n31, mat.n32, mat.n33, mat.n34, 0, 0, 0, 1];
			else
			{
				arrayBuffer_[0] 	= mat.n11; 
				arrayBuffer_[1] 	= mat.n12; 
				arrayBuffer_[2] 	= mat.n13;
				arrayBuffer_[3] 	= mat.n14;
				arrayBuffer_[4] 	= mat.n21; 
				arrayBuffer_[5] 	= mat.n22; 
				arrayBuffer_[6] 	= mat.n23; 
				arrayBuffer_[7] 	= mat.n24,
				arrayBuffer_[8] 	= mat.n31; 
				arrayBuffer_[9] 	= mat.n32; 
				arrayBuffer_[10]	= mat.n33; 
				arrayBuffer_[11]	= mat.n34;
			}
			
			return arrayBuffer_;
		}
		public static function Matrix_interpolate(target:MatrixData, src:MatrixData, des:MatrixData, bias:Number):MatrixData
		{
			Matrix_assignFromElements(target,
				src.n11 + bias * (des.n11 - src.n11),
				src.n12 + bias * (des.n12 - src.n12),
				src.n13 + bias * (des.n13 - src.n13),
				src.n14 + bias * (des.n14 - src.n14),
				src.n21 + bias * (des.n21 - src.n21),
				src.n22 + bias * (des.n22 - src.n22),
				src.n23 + bias * (des.n23 - src.n23),
				src.n24 + bias * (des.n24 - src.n24),
				src.n31 + bias * (des.n31 - src.n31),
				src.n32 + bias * (des.n32 - src.n32),
				src.n33 + bias * (des.n33 - src.n33),
				src.n34 + bias * (des.n34 - src.n34),
				0, 0, 0, 1);
			return target;
		}
	}
}

