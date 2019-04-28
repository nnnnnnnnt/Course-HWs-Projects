import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Scanner;
import java.util.Set;
import java.util.Vector;

class Node {
	   Vector<Integer> currentItemsets;
	   int count; 
	   public Node() {
	       this.currentItemsets=new Vector<Integer>();
	       this.count=0;
	   }  
	   public void countIncrement() {
		   this.count++;
	   }
	   public int getCount() {
		   return count;
	   }  
	}

public class hcrminer {
  public static int minsup;
  public static int opt;
  public static float minconf;
  public static int cttttttt=0;
  public static String outputfilename;
  
  public static void main(String args[]) throws FileNotFoundException{
	  long start = System.currentTimeMillis();
	  minsup=Integer.parseInt(args[0]);
	  minconf=Float.parseFloat(args[1]);
	  String filename=args[2];
	  outputfilename=args[3];
	  opt=Integer.parseInt(args[4]);
	  File file=new File(filename);
	  PreProcessing(file,minsup,opt);
	  System.out.println((System.currentTimeMillis() - start));
  }
  
  public static void PreProcessing(File file,int minsup,int opt) throws FileNotFoundException {
	  Map<Integer, Integer> itemsFrequency = new HashMap<Integer, Integer>();
	  List<Integer> sortedItems = new LinkedList<Integer>();
	  Vector<Integer> itemsetsToRemove = new Vector<Integer>();
	  long start = System.currentTimeMillis();
	  Scanner input = new Scanner(file);
	  while(input.hasNextLine()) {
		  int tmp = Integer.parseInt(input.nextLine().split(" ")[1]);
		  if (itemsFrequency.containsKey(tmp)) {
			  int tmpcnt = itemsFrequency.get(tmp);
			  itemsFrequency.put(tmp, tmpcnt+1);
		  } else {
			  itemsFrequency.put(tmp, 1);
		  }
	  }
	  input.close();
	  System.out.println("Frequency Count Time:  "+ (System.currentTimeMillis() - start));
	  lexico3(file,itemsFrequency,sortedItems,itemsetsToRemove);

  }
  
  public static void lexico3(File file,Map<Integer, Integer> itemsFrequency,List<Integer> sortedItems,Vector<Integer> itemsetsToRemove) throws FileNotFoundException {
	  long start = System.currentTimeMillis();
	  sortedItems.add(999999999);	  
	  itemsFrequency.put(999999999, 0);
	  for (int wanderingItem : itemsFrequency.keySet()) {
		  int i=0;
		  int cnt = itemsFrequency.get(wanderingItem);
		  if (cnt < minsup) {
			  itemsetsToRemove.add(wanderingItem);
		  } else {
		      for(int item: sortedItems) {
			      if(itemsFrequency.get(item)<cnt) {
			     	  sortedItems.add(i, wanderingItem);
				      break;
			      }
			      i++;
		      }
		  }
	  }
	  if(opt==2) Collections.reverse(sortedItems);
	  if(opt==1) sortedItems=new ArrayList<Integer>(itemsFrequency.keySet());
//	  sortedItems.remove(999999999);
//	  for(String x:sortedItems) {System.out.println(x+" "+itemsFrequency.get(x));}
//    itemsFrequency.remove(999999999);
	  System.out.println("Determine LexicoOrder Time:  "+ (System.currentTimeMillis() - start));
	  start = System.currentTimeMillis();
	  ArrayList<ArrayList<Integer>> transactions=ProjectionPrep(file,sortedItems,itemsFrequency,itemsetsToRemove);
	  ArrayList<ArrayList<Integer>> T=new ArrayList<ArrayList<Integer>>();
	  ArrayList<Integer> tmp;
	  System.out.println("Read Transaction Time:  "+ (System.currentTimeMillis() - start));
	  start=System.currentTimeMillis();
	  for(ArrayList<Integer> transaction : transactions) {
		  tmp=new ArrayList<Integer>();
		  for (int s : sortedItems) if (transaction.contains(s)) tmp.add(s);
		  T.add(tmp);
	  }  
//	  for(ArrayList<Integer> q: T) {
//		  for (int we : q) System.out.print(we+" "); 
//		  System.out.println(); 
//	  }
	  System.out.println("Sort Transaction Time:  "+ (System.currentTimeMillis() - start));
	  Node root=new Node();
	  Vector<Node> nodeSet=new Vector<Node>();

	  start = System.currentTimeMillis();
	  Vector<Integer> C = new Vector<Integer>(sortedItems);
	//  for(String s : sortedItems) C.add(s);
	  Projection(root,nodeSet,T,C);
	  System.out.println("Projection Time: "+ (System.currentTimeMillis() - start));
      Iterator<Node> itr = nodeSet.iterator();
      Map<Set<Integer>,Integer> map=new HashMap<Set<Integer>,Integer>();
      Set<Integer> f=new HashSet<Integer>();Node str;
 	  while(itr.hasNext()){
			str = itr.next();
			f=new HashSet<Integer>();
			for(int s:str.currentItemsets) f.add(s);
			map.put(f, str.getCount());
//  		for(String s:str.currentItemsets) {
//				if(s.equals("1")) count++;
//				System.out.print(s+" ");
//		    }
//			System.out.println();
//			System.out.println("count: "+str.count);
		} 
 	 Iterator<Node> itr2 = nodeSet.iterator();
 	 Node str2;int countt;Set<Set<Integer>> H1=new HashSet<Set<Integer>>();Set<Integer> ne=new HashSet<Integer>();
 	 start=System.currentTimeMillis();
 	 int ppp=0;try {
		PrintWriter writer = new PrintWriter(outputfilename, "UTF-8");
		FileWriter fw = new FileWriter(outputfilename);
 		BufferedWriter bw = new BufferedWriter(fw);
		if(minsup<=20) {
	 		while(itr2.hasNext()){
	 			str2 = itr2.next();
	 			countt=str2.getCount();
                for(int tt:str2.currentItemsets) writer.print(tt+" ");
                writer.print("| {} | "+str2.getCount()+" | -1");
                writer.println();
                ppp++;
	 		}
	 		writer.close();
	 	 } else {
	 	 while(itr2.hasNext()){
	 		str2 = itr2.next();
	 		countt=str2.getCount();
	 		ppp++;
	 		Set<Integer> LHS=new HashSet<Integer>();
	 		H1=new HashSet<Set<Integer>>();
	 		for(int ttt:str2.currentItemsets) {
	 			ne=new HashSet<Integer>();
	 			ne.add(ttt);
	 			H1.add(ne);
	 			LHS.add(ttt);
	 		}
	 		
	 	//	for(String s:str2.currentItemsets) LHS.add(s);
	 		APGenRules(map,LHS,H1,0,countt,bw);
	 		bw.flush();
	 	 } }
	} catch ( IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
 	 
 	 
 	 System.out.println("Gen Rules Time: "+ (System.currentTimeMillis()-start));
 	 
 	 System.out.println("Frequent Itemsets Counts: "+ppp+" ;"+"Rules Counts: "+cttttttt);
  }
  
  public static ArrayList<ArrayList<Integer>> ProjectionPrep(File file,List<Integer> sortedItems,Map<Integer, Integer> itemsFrequency,Vector<Integer> itemsetsToRemove) throws FileNotFoundException {   	  
	  Scanner input = new Scanner(file);
	  ArrayList<ArrayList<Integer>> transactions=new ArrayList<ArrayList<Integer>>();
	  int tid;
	  int item;
	  String transaction;
	  while(input.hasNextLine()) {
		  transaction = input.nextLine();
		  tid = Integer.parseInt(transaction.split(" ")[0]);
		  item = Integer.parseInt(transaction.split(" ")[1]);
          if(transactions.size()-1<tid) {
              transactions.add(new ArrayList<Integer>());
          }
          if (!itemsetsToRemove.contains(item)) {
	     	  transactions.get(tid).add(item);
          }
	  }
	  input.close();
	  return transactions;
  }
  
  public static void Projection(Node n,Vector<Node> nodeSet,ArrayList<ArrayList<Integer>> db,Vector<Integer> C) {
	if(C.isEmpty()) return;int j,i;
//	if(n.C.size() > 6) {
	Vector<Integer> C2 = new Vector<Integer>();
	ArrayList<ArrayList<Integer>> newdb = new ArrayList<ArrayList<Integer>>();
	  for(int s : C) {
		  Node newNode = new Node();
		  newNode.currentItemsets=new Vector<Integer>(n.currentItemsets);
		  newNode.currentItemsets.add(s);
		  newdb.clear();
		  for(ArrayList<Integer> transaction : db) {
			  if (transaction.contains(s)) {
				  newNode.countIncrement();
				  i = transaction.indexOf(s);
				  List<Integer> tmp = transaction.subList(i+1, transaction.size());   				  
			//	  for(String temp : tmp) newTransaction.add(temp);
				  ArrayList<Integer> newTransaction = new ArrayList<Integer>(tmp);			  
				  newdb.add(newTransaction);
			  }
		  }
		  if(newNode.getCount() < minsup) continue;
		  j = C.indexOf(s);
		  List<Integer> tmp = C.subList(j+1, C.size());
		  C2 = new Vector<Integer>(tmp);
		  nodeSet.add(newNode);
		  Projection(newNode,nodeSet,newdb,C2);
	  }
  }
  public static void APGenRules(Map<Set<Integer>,Integer> map,Set<Integer> FQIS,Set<Set<Integer>> H,int level,int support,BufferedWriter writer) {
	  int k=FQIS.size();
	  level++;
	  if(k>level) {
		  float d=1;
		  Set<Set<Integer>> consequentToRemove=new HashSet<Set<Integer>>();
		  for(Set<Integer> consequent: H) {
			  FQIS.removeAll(consequent);
			  if(FQIS.isEmpty()) {return;}
			  Iterator<Set<Integer>> itr2 = map.keySet().iterator();		  
              while(itr2.hasNext()) {
            	  Set<Integer> tmp=itr2.next();
            	  if(tmp.equals(FQIS)) {d=(float)map.get(tmp);break;}
              }
			  float conf=(float)support/d;
			  if (conf>=(minconf)) {
				  
					try {
						for(int L:FQIS) writer.write(L+" ");
						writer.write("| ");
		    			for(int R:consequent) writer.write(R+" ");
		    			writer.write("| "+support+" | "+conf);
		    			writer.newLine();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				  cttttttt++;
			  } else {
				  consequentToRemove.add(consequent);
			  }
			  FQIS.addAll(consequent);
		  }
		  H.removeAll(consequentToRemove);
		  Set<Set<Integer>> H1=CandidateGenPrune(H,consequentToRemove);
		  APGenRules(map,FQIS,H1,level,support,writer);
	  }
  }
  
  public static Set<Set<Integer>> CandidateGenPrune(Set<Set<Integer>> H,Set<Set<Integer>> consequentToRemove) {
	  Set<Set<Integer>> result=new HashSet<Set<Integer>>();
	  Set<Integer> HS1tmp=new HashSet<Integer>();Set<Integer> HS=new HashSet<Integer>();   
	  for(Set<Integer> HS1 : H) {
		  for(Set<Integer> HS2 : H) {
			  HS1tmp=new HashSet<Integer>(HS1);
			  HS1tmp.removeAll(HS2);
			  if (HS1tmp.size()==1) {
				  boolean flag=true;
				  HS1tmp.addAll(HS2);
				  HS=new HashSet<Integer>(HS1tmp); 
				  HashSet<Integer> HStmp=new HashSet<Integer>(HS);
				  for(int g:HS) {
					  HStmp.remove(g);
					  if(consequentToRemove.contains(HStmp)) {flag=false;HStmp.add(g);break;}
					  HStmp.add(g);
				  }
				  if(flag && !result.contains(HS)) result.add(HS);
			  }
		  }
	  }
	return result;  	  
  }
}

