
import java.util.ArrayList;
import java.util.HashMap;
import java.awt.image.Raster;
import java.io.IOException;
import java.io.File;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;

public class RPoints{
	public static Raster map;
	public static int h;
	public static int w;


	//End product: a list of [[x,y,type]]
	
	//For that: Go through every pixel on the map:

	//...wait... thats for the actual map.


	//So first I need to load in the map

	public class Color{
		public int r, g, b;

		public Color(int[] s){
			this.r = s[0];
		}



		@Override
		public int hashCode(){
			return this.r;
		}

		public String toString(){
			return "(" + this.r + ")";
		}

		public String bcolor(){
			return "[" + this.r + "]";
		}

		public boolean equals(Object other){
			return this.hashCode() == other.hashCode();
		}
	}

	public Color getPixel(int x,int y){
		int[] cols = new int[4];
		map.getPixel(x,y,cols);
		Color col = new Color(cols);
		return col;	
	}

	public String getWidth(int val){
		switch(val){
			case 0:
				return "0.3";
			case 100:
				return "0.4";
			case 200:
				return "0.5";
			default:
				return "0";
		}
	}

	public void newMain(){
		File input;
		try{
			input = new File("rhorea.png");
			BufferedImage buffr = ImageIO.read(input);
    		BufferedImage convertedImg = new BufferedImage(buffr.getWidth(), buffr.getHeight(), BufferedImage.TYPE_INT_RGB);
    		convertedImg.getGraphics().drawImage(buffr, 0, 0, null);


			//System.out.println(buffh.)
			map = convertedImg.getData();
			h = map.getHeight();
			w = map.getWidth();
			Color col = this.getPixel(0,0);
			//System.out.println(col);
			//System.out.println(h);
			//System.out.println(w);
			int i = 0;
			System.out.print("(");
			for (int y = 0; y < h; y++) {
  				for (int x = 0; x < w; x++){
  					Color color = this.getPixel(x,y);
  					if (color.r != 255){
  						System.out.print(",(" + x + "," + y + "," + this.getWidth(color.r) + ")");
  						i = i +1;
  					}
  				}
  			}
  			System.out.print(")");
  			System.out.println(i);
		}catch(IOException e){
			e.printStackTrace();
			return;
		}
	}

	public static void main(String[] args){
		RPoints main = new RPoints();
		main.newMain();
	}
}


