
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

public class kcluster {
	static int K;
	static int trails_times;
	static String input_file_name;
	static String criterion_f;
	static String class_file_name;
    static String output_file_name;
    static Map<Integer,String> class_map;
    static Set<String> class_set;
    
	public static void main(String args[]) throws IOException {
		input_file_name = args[0];
		criterion_f = args[1];
		class_file_name = args[2];
		K = Integer.parseInt(args[3]);
		trails_times = Integer.parseInt(args[4]);
		output_file_name = args[5];
		String tuple;
		class_map = new HashMap<Integer,String>();
		class_set = new HashSet<String>();
		BufferedReader input = new BufferedReader(new FileReader(class_file_name));
		while ((tuple = input.readLine()) != null) {
			class_map.put(Integer.parseInt(tuple.split(",")[0]), tuple.split(",")[1]);
			class_set.add(tuple.split(",")[1]);
		}
		Map<Integer,Vector> vectors = Tuple_to_Vector();//generate vector representations of documents
		double SSE = 100000000.0;double I2 = 0.0;
		if(criterion_f.equals("SSE")) for(int i = 1; i <= trails_times * 2 - 1;i += 2) SSE = SSE(vectors,i,SSE); // criterion function:SSE
		if(criterion_f.equals("I2")) for(int i = 1; i <= trails_times * 2 - 1;i += 2) I2 = I2(vectors,i,I2);
		System.out.println();
	}
	
	static Map<Integer,Vector> Tuple_to_Vector() throws IOException {
		BufferedReader input = new BufferedReader(new FileReader(input_file_name));
		String tuple;int did;int dnum;double freq;
		Map<Integer,Vector> vectors = new HashMap<Integer,Vector>(); 
		while ((tuple = input.readLine()) != null) {
			 did = Integer.parseInt(tuple.split(",")[0]);
			 dnum = Integer.parseInt(tuple.split(",")[1]);
			 freq = Double.parseDouble(tuple.split(",")[2]);
			 if(vectors.containsKey(did)) {
				 vectors.get(did).get_dict().put(dnum, freq);
			 } else {
				 vectors.put(did, new Vector(did));
				 vectors.get(did).get_dict().put(dnum, freq);
			 }
		}
		input.close();
		return vectors;
	}
	
	static double SSE(Map<Integer,Vector> vectors,int seed,double SSE) throws FileNotFoundException, UnsupportedEncodingException {
		Random random = new Random(seed); // set random seed
		
		Set<Integer> initial_clusters = new HashSet<Integer>();
		int max_id = 0;
		for(int q : vectors.keySet()) if(max_id < q) max_id = q; 
		while(initial_clusters.size() < K) {
			int tmp = random.nextInt(max_id) + 1;
			if(vectors.keySet().contains(tmp)) initial_clusters.add(tmp);
		} // use set to get K random non-repeating document id.
		
		ArrayList<Cluster> clusters = new ArrayList<Cluster>();
		Iterator<Integer> iterator = initial_clusters.iterator();
		while(iterator.hasNext()) {
			int selected_num = iterator.next();
			Cluster new_cluster = new Cluster(vectors.get(selected_num)); // set cluster centroid, add the initial vector to its vectors list.
			clusters.add(new_cluster);
		} //initialize K clusters with randomly selected centroids(actual vectors)
		
		for (int m = 0; m < 10; m++) {
		    for (int j : vectors.keySet()) {
		    	if(m == 0 && initial_clusters.contains(j)) continue;
			    double min = 10000000.0;int min_num = 0;
			    for(int i = 0; i < K; i++) {
			    	double d = dist(vectors.get(j),clusters.get(i).get_centroid());
				    if (d < min) {min_num = i;min = d;}
			    }
			    clusters.get(min_num).add_member(vectors.get(j));
		    } // assign each document to its closest cluster		
		    for (Cluster cluster : clusters) {
		    	cluster.update_centroid();// update centroid
		    	if(m<9) cluster.vectors_clear();
		    }
		}// ten iterations
		double sse = 0.0;
		for (Cluster cluster : clusters) sse += cluster.compute_SSE();
		if (sse < SSE) {
			PrintWriter writer = new PrintWriter(output_file_name);
			for(int l = 0; l < clusters.size();l++) {
				for (Vector vector : clusters.get(l).get_members()) {
					writer.write(vector.get_document_id()+","+l);
					writer.write("\n");
					String class_name = class_map.get(vector.get_document_id());
					if(clusters.get(l).get_matrix_row().containsKey(class_name)) {
						int v = clusters.get(l).get_matrix_row().get(class_name);
						v++;
						clusters.get(l).get_matrix_row().put(class_name, v);
					}else {
						clusters.get(l).get_matrix_row().put(class_name, 1);
					}
				}
			}
			SSE = sse;
			writer.write(" ");
			for(String s : class_set) writer.write(','+s);
			writer.write(",entropy,purity");double sum_entropy = 0;double sum_purity=0;
			for(int l = 0 ;l < clusters.size();l++) {
				writer.write("\n");
				writer.write("Cluster "+l+" : ");
				int sum = 0;
				for(String s : class_set) {
					if(clusters.get(l).get_matrix_row().containsKey(s)) {
						int sv = clusters.get(l).get_matrix_row().get(s);
					    writer.write(String.valueOf(','));
					    writer.write(String.valueOf(sv));
					    sum += sv;
				    }else {
					    writer.write(String.valueOf(",0"));
				    }
			    }
				double entropy=0.0;double pil_max = 0;
				for(String s : class_set) {
					if(clusters.get(l).get_matrix_row().containsKey(s)) {
						int sv = clusters.get(l).get_matrix_row().get(s);
						double pil = (double)sv/sum;
						entropy += (pil * Math.log(pil)/Math.log(2));
						if(pil>pil_max) pil_max=pil;
					}
				}
				writer.write(String.valueOf(','));
				writer.write(String.valueOf(Math.abs(entropy)));
				writer.write(String.valueOf(','));
				writer.write(String.valueOf(pil_max));
			//	writer.write(String.valueOf("=MAX(B"+(8092+l)+":U"+(8092+l)+")"+"/"+sum));
			//	writer.write(String.valueOf(','));
			//	writer.write(String.valueOf(sum));
				sum_entropy += (sum * entropy / 8090);
				sum_purity +=(sum * pil_max / 8090);
			}
			writer.write("\n");
			writer.write("Total : ");
			int i = 0;
			for(String s:class_set) {
				writer.write(",=SUM("+(char)('B'+i)+"8092:"+(char)('B'+i)+(8091+K)+")");
				i++;
			}
			writer.write(String.valueOf(","+Math.abs(sum_entropy)));
			writer.write(String.valueOf(","+sum_purity));
			writer.write(",Best value of SSE : "+sse);
			writer.flush();
		}
		System.out.println("Seed "+seed+" : "+sse);
		return SSE;	
	}
	
	static double I2(Map<Integer,Vector> vectors,int seed,double I2) throws FileNotFoundException {
        Random random = new Random(seed); // set random seed
		
		Set<Integer> initial_clusters = new HashSet<Integer>();
		int max_id = 0;
		for(int q : vectors.keySet()) if(max_id < q) max_id = q; 
		while(initial_clusters.size() < K) {
			int tmp = random.nextInt(max_id) + 1;
			if(vectors.keySet().contains(tmp)) initial_clusters.add(tmp);
		} // use set to get K random non-repeating document id.
		
		ArrayList<Cluster> clusters = new ArrayList<Cluster>();
		Iterator<Integer> iterator = initial_clusters.iterator();
		while(iterator.hasNext()) {
			int selected_num = iterator.next();
			Cluster new_cluster = new Cluster(vectors.get(selected_num)); // set cluster centroid, add the initial vector to its vectors list.
			clusters.add(new_cluster);
		} //initialize K clusters with randomly selected centroids(actual vectors)
	    
		for (int m = 0; m < 10; m++) {
		    for (int j : vectors.keySet()) {
		    	if(m == 0 && initial_clusters.contains(j)) continue;
			    double max = 0;int max_num = 0;
			    for(int i = 0; i < K; i++) {
			    	double sim = cosine_sim(vectors.get(j),clusters.get(i).get_centroid());
				    if (sim > max) {max_num = i;max = sim;}
			    }
			    clusters.get(max_num).add_member(vectors.get(j));
			    clusters.get(max_num).get_centroid().add(vectors.get(j));
			//    clusters.get(max_num).get_centroid().normalize();
		    } // assign each document to its closest cluster		
		    for (Cluster cluster : clusters) {
		    	if(m<9) cluster.vectors_clear();
		    }
		}// ten iterations
		
		double i2 = 0.0;
		for (Cluster cluster : clusters) i2 += cluster.compute_I2();
		if (i2 > I2) {
			PrintWriter writer = new PrintWriter(output_file_name);
			for(int l = 0; l < clusters.size();l++) {
				for (Vector vector : clusters.get(l).get_members()) {
					writer.write(vector.get_document_id()+","+l);
					writer.write("\n");
					String class_name = class_map.get(vector.get_document_id());
					if(clusters.get(l).get_matrix_row().containsKey(class_name)) {
						int v = clusters.get(l).get_matrix_row().get(class_name);
						v++;
						clusters.get(l).get_matrix_row().put(class_name, v);
					}else {
						clusters.get(l).get_matrix_row().put(class_name, 1);
					}
				}
			}
			I2 = i2;
			writer.write(" ");
			for(String s : class_set) writer.write(','+s);
			writer.write(",entropy,purity");double sum_entropy = 0;double sum_purity=0;
			for(int l = 0 ;l < clusters.size();l++) {
				writer.write("\n");
				writer.write("Cluster "+l+" : ");
				int sum = 0;
				for(String s : class_set) {
					if(clusters.get(l).get_matrix_row().containsKey(s)) {
						int sv = clusters.get(l).get_matrix_row().get(s);
					    writer.write(String.valueOf(','));
					    writer.write(String.valueOf(sv));
					    sum += sv;
				    }else {
					    writer.write(String.valueOf(",0"));
				    }
			    }
				double entropy=0.0;double pil_max = 0;
				for(String s : class_set) {
					if(clusters.get(l).get_matrix_row().containsKey(s)) {
						int sv = clusters.get(l).get_matrix_row().get(s);
						double pil = (double)sv/sum;
						entropy += (pil * Math.log(pil)/Math.log(2));
						if(pil>pil_max) pil_max=pil;
					}
				}
				writer.write(String.valueOf(','));
				writer.write(String.valueOf(Math.abs(entropy)));
				writer.write(String.valueOf(','));
				writer.write(String.valueOf(pil_max));
			//	writer.write(String.valueOf("=MAX(B"+(8092+l)+":U"+(8092+l)+")"+"/"+sum));
			//	writer.write(String.valueOf(','));
			//	writer.write(String.valueOf(sum));
				sum_entropy += (sum * entropy / 8090);
				sum_purity +=(sum * pil_max / 8090);
			}
			writer.write("\n");
			writer.write("Total : ");
			int i = 0;
			for(String s:class_set) {
				writer.write(",=SUM("+(char)('B'+i)+"8092:"+(char)('B'+i)+(8091+K)+")");
				i++;
			}
			writer.write(String.valueOf(","+Math.abs(sum_entropy)));
			writer.write(String.valueOf(","+sum_purity));
			writer.write(",Best value of I2 : "+i2/10);
			writer.flush();
		}
		System.out.println("Seed "+seed+" : "+i2/10);
		return I2;	
	}
	
	static double cosine_sim(Vector a,Vector b) {
		double sim = 0.0;
		double a_l = 0.0;double b_l = 0.0;
		for(double au : a.get_dict().values()) a_l += Math.pow(au, 2);
		for(double bu : b.get_dict().values()) b_l += Math.pow(bu, 2);
		a_l = Math.pow(a_l, 0.5);b_l = Math.pow(b_l, 0.5);
		for(int dnum : a.get_dict().keySet()) if(b.get_dict().containsKey(dnum)) sim += a.get_dict().get(dnum) * b.get_dict().get(dnum);
		return sim/(a_l*b_l);
	}
	
	static double dist(Vector a,Vector b) {
		double sum = 0;
		for(int dnum : a.get_dict().keySet()) {
			try {
				sum += Math.pow((b.dict_get_value(dnum)-a.dict_get_value(dnum)), 2);
			} catch(Exception e) {
				sum += Math.pow(a.dict_get_value(dnum), 2);
			}
		}
		for(int dnum : b.get_dict().keySet()) {
			try {double f = a.dict_get_value(dnum);}
			catch (Exception e){
				sum += Math.pow(b.dict_get_value(dnum), 2);
			}
		}
		return sum;
	}
}

class Vector {
	private Map<Integer,Double> dict;
	private int document_id;
    
	public Vector() {
		this.dict = new HashMap<Integer,Double>();
		this.document_id = 0;
	}
	
    public Vector(int id) {
    	this.dict = new HashMap<Integer,Double>();
		this.document_id = id;
	}
	
	public Vector(Vector vector) {
		this.dict = new HashMap<Integer,Double>(vector.get_dict());
		this.document_id = vector.document_id;
	}
	
	public void normalize() {
		double sum = 0;
		for(double s : this.dict.values()) sum += Math.pow(s, 2);
		sum = Math.pow(sum, 0.5);
		for(int k: this.dict.keySet()) {
			double s = this.dict.get(k);
			s = s / sum;
			this.dict.put(k, s);
		}
	}
	
	public void set_document_id(int id) {
		this.document_id = id;
	}
	
	public void dict_add(int dnum,double freq) {
		this.dict.put(dnum, freq);
	}
	
	public double dict_get_value(int dnum) {
		return this.dict.get(dnum);
	}
	
	public void print_dict() {
	    for(int key : this.dict.keySet()) System.out.print(key+" : "+this.dict.get(key)+"; ");	
	}
	
	public int get_document_id() {
		return this.document_id;
	}
	
	public Map<Integer,Double> get_dict(){
		return this.dict;
	}
	
	public void add(Vector vector) {
		Iterator<Integer> iterator = vector.get_dict().keySet().iterator();
	    while(iterator.hasNext()) {
	    	int s = iterator.next();
	    	try {
	    		double p = this.get_dict().get(s);
	    		p += vector.get_dict().get(s);
	    		this.get_dict().put(s, p);
	    	} catch (Exception e) {
	    		this.get_dict().put(s, vector.get_dict().get(s));
	    	}
	    }
	}
}

class Cluster {
	private Vector centroid;
	private ArrayList<Vector> vectors;
	private Map<String,Integer> matrix_row;

	
	public Cluster(Vector centroid) {
		this.centroid = new Vector(centroid);
		this.vectors = new ArrayList<Vector>();
		this.vectors.add(centroid);
		this.matrix_row = new HashMap<String,Integer>();
	}	
	
	public void vectors_clear() {
		this.vectors.clear();
	}
	
	public Vector get_centroid() {
		return this.centroid;
	}

	public void add_member(Vector vector) {
		this.vectors.add(vector);
	}
	
	public ArrayList<Vector> get_members(){
		return this.vectors;
	}
	public void print_cluster() {
		for(Vector vector : this.vectors) System.out.print(vector.get_document_id() + ", ");
		System.out.println();
	}
	
	public void update_centroid() {
		Vector new_centroid = new Vector();
		Iterator<Vector> iterator = this.vectors.iterator();
		int len = 0;
		while (iterator.hasNext()) {new_centroid.add(iterator.next());len++;}
		Iterator<Integer> iterator2 = new_centroid.get_dict().keySet().iterator();
		while (iterator2.hasNext()) {
			int s = iterator2.next();
			double new_freq = new_centroid.get_dict().get(s);
			new_centroid.get_dict().put(s, new_freq/len);
		}
		this.centroid = new Vector(new_centroid);
	}
	
	public double compute_SSE() {
		double sse = 0;
		for(Vector vector : this.vectors) {
			sse += kcluster.dist(vector,this.centroid);
		}
		return sse;
	}
	
	public double compute_I2() {
		double I2 = 0;
		for(double v : this.centroid.get_dict().values()) I2 += Math.pow(v, 2);
		I2 = Math.pow(I2, 0.5);
		return I2;
	}
	
	public Map<String,Integer> get_matrix_row(){
		return this.matrix_row;
	}
}
