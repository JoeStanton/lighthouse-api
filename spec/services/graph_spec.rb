require './app/services/graph.rb'

describe Graph do
  describe ".new" do
    g = Graph.new "new_test"

    it "should be empty" do
      g.nodes.should be_empty
      g.edges.should be_empty
    end
  end

  describe ".path" do
    it "should be constructed based on the environment" do
      Graph.path("test").should == "db/test.db"
    end
  end

  describe "load / save", slow: true do
    describe ".load" do
      it "should return a new database if one doesn't exist" do
        Graph.should_receive(:new).with("fake")
        Graph.load("fake")
      end
    end

    it "should round-trip a database successfully" do
      sample = Graph.load "round-trip"
      sample.nodes = nodes = [1, 2, 3]
      sample.edges = edges = [ {from: 1, to: 2} ]
      sample.save

      loaded = Graph.load "round-trip"
      loaded.nodes.should == nodes
      loaded.edges.should == edges

      File.unlink "db/round-trip.db"
    end
  end
end

describe Node do
  before(:all) do
    @graph = Graph.new "relate"
    @n1 = Node.new(@graph)
    @n2 = Node.new(@graph)

    @graph.nodes << @n1
    @graph.nodes << @n2
    @n1.relate(@n2, :depends_on)
  end

  describe "#relate" do
    it "should create the relationship" do

      edge = @graph.edges.first
      @graph.edges.should have(1).item
      edge.from.should == @n1
      edge.to.should == @n2
      edge.type.should == :depends_on
    end

    it "should not create duplicate relationships" do
      @n1.relate(@n2, :depends_on)
      @graph.edges.should have(1).item
    end
  end

  describe "#out" do
    it "should list related nodes via outgoing relationships" do
      @n1.out.should == [@n2]
    end

    it "should constrain by type" do
      @n1.out(:depends_on).should == [@n2]
      @n1.out(:nothing).should be_empty
    end
  end

  describe "#in" do
    it "should list related nodes via incoming relationships" do
      @n2.in.should == [@n1]
    end

    it "should constrain by type" do
      @n2.in(:depends_on).should == [@n1]
      @n2.in(:nothing).should be_empty
    end
  end
end