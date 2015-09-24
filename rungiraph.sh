#!/bin/bash

case "$1" in

	connectedcomponents) 	
		EXAMPLE=ConnectedComponentsComputation
		echo "running giraph example" $EXAMPLE "..."
		;;

	pagerank) 	EXAMPLE=SimplePageRankComputation
			echo "running giraph example" $EXAMPLE "..."
			;;

	shortestpaths) 	EXAMPLE=SimpleShortestPathsComputation
			echo "running giraph example" $EXAMPLE "..."
			;;

	*)		echo "unknown giraph example" $1 "; exiting ..."
			exit 1
			;;
esac  

hadoop fs -rm -r -f /giraph-tutorial/output/$1

case "$1" in
	connectedcomponents)
		hadoop jar \
			target/giraph-mp-1.0-SNAPSHOT-jar-with-dependencies.jar org.apache.giraph.GiraphRunner \
			$EXAMPLE \
			-vif org.apache.giraph.io.formats.IntIntNullTextInputFormat \
			-vip /giraph-tutorial/input/tiny2_graph.txt \
			-vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat \
			-op /giraph-tutorial/output/$1 \
			-w 1 \
			-ca giraph.SplitMasterWorker=false \
			#
		;;

	pagerank)
		hadoop jar \
			giraph-examples.jar org.apache.giraph.GiraphRunner \
			org.apache.giraph.examples.$EXAMPLE \
			-vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat \
			-vip /giraph-tutorial/input/tiny_graph.txt \
			-vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat \
			-op /giraph-tutorial/output/$1 \
			-w 1 \
			-ca giraph.SplitMasterWorker=false \
			-mc org.apache.giraph.examples.$EXAMPLE\$SimplePageRankMasterCompute \
			#
		;;

	shortestpaths)
		hadoop jar \
			giraph-examples.jar org.apache.giraph.GiraphRunner \
			org.apache.giraph.examples.$EXAMPLE \
			-vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat \
			-vip /giraph-tutorial/input/tiny_graph.txt \
			-vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat \
			-op /giraph-tutorial/output/$1 \
			-w 1 \
			-ca giraph.SplitMasterWorker=false \
			-ca SimpleShortestPathsVertex.sourceId=0 \
			#
		;;

	*)	echo "this should not happen; EXAMPLE=" $EXAMPLE "; exiting ..."
		exit 1
		;;
esac

mkdir otput/$1
hadoop fs -cat /giraph-tutorial/output/$1/* > otput/$1/part-m-00000
#hadoop fs -get /giraph-tutorial/output/connected-components/* otput
more otput/$1/part-m-00000
