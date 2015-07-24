package com.jonnybomb.mentalmodeler.utils.visual
{
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class DrawingUtil
	{
		public static const DEFAULT_ELLIPSE_OBJ:Object = {tr:0, tl:0, br:0, bl:0};
		
		public static function drawCameraIcon(r:Rectangle, color:uint = 0xffffff):Sprite {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(color, 1);
			var ellipse:int = 5;
			var bodyPct:Number = 0.8;
			var yAdj:Number = r.height * (1 - bodyPct);
			var adjY:Number = r.y + yAdj;
			var bodyPctX:Number = 0.3;
			var xAdj:Number = r.width * (1 - bodyPctX);
			var adjX:Number = r.x + xAdj;
			g.drawRoundRect(r.x, adjY, r.width, r.height * bodyPct, ellipse);
			g.drawCircle(r.x + r.width/2, adjY + (r.height * bodyPct)/2, 5);// + (r.height * bodyPct)/2, 6);
			g.endFill();
			g.beginFill(color, 1);
			g.drawCircle(r.x + r.width/2, adjY + (r.height * bodyPct)/2, 3);
			g.endFill();
			g.beginFill(color, 1);
			var offset:Number = 0.275;
			var offsetX:Number = r.x + offset * r.width;
			var offsetY:Number = r.y;// + offset * r.height;
			var offsetWidth:Number = r.width * (1 - (offset * 2));
			var offsetHeight:Number = r.height * (1 - bodyPct) + 1;
			g.drawRoundRect(offsetX, offsetY, offsetWidth, offsetHeight, ellipse);
			g.endFill();
			
			return s;
		}
		
		public static function drawDeleteIcon():Sprite {
			var bodyWidth:int = 8;
			var bodyHeight:int = 8;
			var topHeight:int = 2;
			var topTopHeight:int = 1;
			var topBrimExtra:int = 1;
			var topTopBrimExtra:int = 2;
			var spacing:int = 1;
			var bodyTop:int = topTopHeight + topHeight + spacing;		
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(0xffffff);;
			g.moveTo(topBrimExtra, bodyTop);
			g.lineTo(topBrimExtra + bodyWidth, bodyTop);
			g.lineTo(topBrimExtra + bodyWidth, bodyTop + bodyHeight);
			g.lineTo(topBrimExtra, bodyTop + bodyHeight);
			g.lineTo(topBrimExtra, bodyTop);
			g.moveTo( 0, topTopHeight + topHeight);
			g.lineTo(topBrimExtra*2 + bodyWidth, topTopHeight + topHeight);
			g.lineTo(topBrimExtra*2 + bodyWidth, topTopHeight);
			g.lineTo(topBrimExtra + bodyWidth - topTopBrimExtra, topTopHeight);
			g.lineTo(topBrimExtra + bodyWidth - topTopBrimExtra, 0);
			g.lineTo(topBrimExtra + topTopBrimExtra, 0);
			g.lineTo(topBrimExtra + topTopBrimExtra, topTopHeight);
			g.lineTo(0, topTopHeight);
			g.lineTo(0, topTopHeight + topHeight);
			g.endFill();	
			return s;
		}
		
		public static function drawFullscreenToggleIcon(expand:Boolean, r:Rectangle, iconSide:int, color:uint = 0xffffff):Sprite {
			var s:Sprite = new Sprite();
			for (var i:int=0; i<4; i++) {
				var a:Sprite = s.addChild( drawArrow(color, iconSide) ) as Sprite;
				if (expand) {	
					switch (i) {
						case 0: // tl
							break;
						case 1: // tr
							a.x = r.width;
							a.rotation = 90;
							break;
						case 2: // br
							a.x = r.width;
							a.y = r.height;
							a.rotation = 180;
							break;
						case 3: // bl
							a.y = r.height;
							a.rotation = 270;
							break;
					}
				}
				else {
					switch (i) {
						case 0: // tl
							a.rotation = 180;
							a.x = iconSide;
							a.y = iconSide;
							break;
						case 1: // tr
							a.rotation = 270;
							a.x = r.width - iconSide;
							a.y = iconSide;
							break;
						case 2: // br
							a.rotation = 0;
							a.x = r.width - iconSide;
							a.y = r.height - iconSide;
							break;
						case 3: // bl
							a.rotation = 90;
							a.x = iconSide;
							a.y = r.height - iconSide;
							break;		
					}
				} 	
			}
			return s;
		}
		
		public static function drawArrow(color:uint = 0xffffff, side:int = 4):Sprite {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(color, 1);
			g.moveTo(0, 0);
			g.lineTo(side, 0);
			g.lineTo(0, side);
			g.lineTo(0, 0);
			g.moveTo(1, 1);
			g.lineStyle(2, 0xffffff);
			g.lineTo(side, side);
			return s;
		}
		
		/*
		public static function drawArrow(color:uint = 0xffffff, alpha:Number = 1, arrowHeight:int = 4, arrowWidth:int = 3, stemHeight:int = 2, stemWidth:int = 2):Sprite {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(color, alpha);
			g.moveTo(0, 0);
			g.lineTo(-arrowWidth, arrowHeight);
			g.lineTo(-stemWidth/2, arrowHeight);
			g.lineTo(-stemWidth/2, arrowHeight + stemHeight);
			g.lineTo(stemWidth/2, arrowHeight + stemHeight);
			g.lineTo(stemWidth/2, arrowHeight);
			g.lineTo(arrowWidth, arrowHeight);
			g.lineTo(0, 0);
			return s;
		}
		*/
		
		public static function drawSquiggly(s:Sprite, w:int, color:uint = 0xFF0000, lineThickness:Number = 0.25):void
		{
			var segmentW:int = 2;
			var segmentH:int = 2;	
			var g:Graphics = s.graphics;
			
			g.lineStyle(lineThickness, color);
			g.moveTo(0, 0)
				
			var nX:int = 0;
			var nY:int = 0;
			while(nX + segmentW <= w)
			{
				nX += segmentW;
				nY = (nY < segmentH) ? segmentH : 0;
				g.lineTo(nX, nY); 
			}
			
			var remainder:int = w - nX;
			if (remainder > 0)
			{
				var pct:Number = remainder / segmentW;
				nX += remainder;
				nY = (nY < segmentH) ? segmentH : 0;
				nY = (nY == 0) ? segmentH - segmentH * pct : segmentH * pct;
				g.lineTo(nX, nY);
			}
				
			g.endFill();
		}
		
		public static function drawRect(s:Sprite, w:int, h:int, colors:ColorData, _stroke:int = 0, ellipse:int = 0):void
		{
			//trace("DrawingUtil >> drawRect\n\tw:"+w+"\n\th:"+h+"\n\t_stroke:"+_stroke+"\n\tellipse:"+ellipse+"\n\tcolors:"+colors);
			s.graphics.clear();
			var matrix:Matrix = new Matrix();
			
			//adjust size for stroke
			var wFill:int;
			var hFill:int;
			var eFill:int;
			var offset:int;
			
			if (colors.stroke)
			{
				wFill = w - _stroke * 2;
				hFill = h - _stroke * 2;
				eFill = int(ellipse) - _stroke; // * 2;
				eFill = eFill < 0 ? 0 : eFill;
				offset = _stroke;
			}
			else
			{
				wFill = w;
				hFill = h;
				eFill = int(ellipse);
				offset = 0;
			}
			
			//============== fill ==============
			if (colors.fill)
			{
				if (colors.fill is GradientColorData)
				{
					// fill is a gradient
					var gFill:GradientColorData = GradientColorData(colors.fill);
					matrix.createGradientBox(wFill, hFill, gFill.rotation, offset, offset); 
					s.graphics.beginGradientFill(gFill.gradType, gFill.colors, gFill.alphas, gFill.ratios, matrix);
					
				}
				else 
				{
					// fill is solid
					var cFill:ColorExtended = ColorExtended(colors.fill);
					s.graphics.beginFill(cFill.color, cFill.alpha);	
				}
				
				s.graphics.drawRoundRect(offset, offset, wFill, hFill, eFill, eFill);
				s.graphics.endFill();
			}
			
			//============== stroke ==============
			if (colors.stroke)
			{
				if (colors.stroke is GradientColorData)
				{
					// stroke is a gradient
					var gStroke:GradientColorData = GradientColorData(colors.stroke);
					matrix.createGradientBox(w, h, gStroke.rotation, 0, 0);
					s.graphics.beginGradientFill(gStroke.gradType, gStroke.colors, gStroke.alphas, gStroke.ratios, matrix);
				}
				else 
				{
					// stroke is solid
					var cStroke:ColorExtended = ColorExtended(colors.stroke)
					s.graphics.beginFill(cStroke.color, cStroke.alpha);
				}
				
				// cut-out inside to make fill appear as stroke
				s.graphics.drawRoundRect(0, 0, w, h, ellipse, ellipse);
				s.graphics.drawRoundRect(offset, offset, wFill, hFill, eFill, eFill);
				s.graphics.endFill();
			}
		}
		
		public static function drawComplexRect(s:Sprite, w:int, h:int, colors:ColorData, _stroke:int = 0, ellipseObj:Object = null):void
		{
			//trace("DrawingUtil >> drawComplexRect\n\tw:"+w+"\n\th:"+h+"\n\t_stroke:"+_stroke+"\n\tcolors:"+colors);
			s.graphics.clear();
			
			if (ellipseObj == null)
				ellipseObj = DEFAULT_ELLIPSE_OBJ;
			
			var matrix:Matrix = new Matrix();
			
			//adjust size for stroke
			var wFill:int;
			var hFill:int;
			var eFillObj:Object = {};
			var offset:int;
			var prop:String;
			
			if (colors.stroke)
			{
				wFill = w - _stroke * 2;
				hFill = h - _stroke * 2;
				
				for (prop in ellipseObj)
				{
					eFillObj[prop] = ellipseObj[prop] - _stroke;// * 2;
					eFillObj[prop] = eFillObj[prop] < 0 ? 0 : eFillObj[prop];
				}
				offset = _stroke;
			}
			else
			{
				wFill = w;
				hFill = h;
				
				for (prop in ellipseObj)
					eFillObj[prop] = ellipseObj[prop];
				
				offset = 0;
			}
			
			//============== fill ==============
			if (colors.fill)
			{
				if (colors.fill is GradientColorData)
				{
					// fill is a gradient
					var gFill:GradientColorData = GradientColorData(colors.fill);
					matrix.createGradientBox(wFill, hFill, gFill.rotation, offset, offset); 
					s.graphics.beginGradientFill(gFill.gradType, gFill.colors, gFill.alphas, gFill.ratios, matrix);
					
				}
				else 
				{
					// fill is solid
					var cFill:ColorExtended = ColorExtended(colors.fill);
					s.graphics.beginFill(cFill.color, cFill.alpha);	
				}
				
				s.graphics.drawRoundRectComplex(offset, offset, wFill, hFill, eFillObj.tl, eFillObj.tr, eFillObj.bl, eFillObj.br);
				s.graphics.endFill();
			}
			
			//============== stroke ==============
			if (colors.stroke)
			{
				if (colors.stroke is GradientColorData)
				{
					// stroke is a gradient
					var gStroke:GradientColorData = GradientColorData(colors.stroke);
					matrix.createGradientBox(w, h, gStroke.rotation, 0, 0);
					s.graphics.beginGradientFill(gStroke.gradType, gStroke.colors, gStroke.alphas, gStroke.ratios, matrix);
				}
				else 
				{
					// stroke is solid
					var cStroke:ColorExtended = ColorExtended(colors.stroke)
					s.graphics.beginFill(cStroke.color, cStroke.alpha);
				}
				
		
				// cut-out inside to make fill appear as stroke
				s.graphics.drawRoundRectComplex(0, 0, w, h, ellipseObj.tl, ellipseObj.tr, ellipseObj.bl, ellipseObj.br);
				s.graphics.drawRoundRectComplex(offset, offset, wFill, hFill, eFillObj.tl, eFillObj.tr, eFillObj.bl, eFillObj.br);
				s.graphics.endFill();
			}
		}
	}
}