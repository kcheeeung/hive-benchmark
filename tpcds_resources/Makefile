
all: target/lib/dsdgen.jar target/tpcds-gen-1.0-SNAPSHOT.jar

target/tpcds-gen-1.0-SNAPSHOT.jar: $(shell find -name *.java) 
	mvn package

target/tpcds_2.10.zip: tpcds_2.10.zip
	mkdir -p target/
	cp tpcds_2.10.zip target/tpcds_2.10.zip

target/lib/dsdgen.jar: target/tools/dsdgen
	cd target/; mkdir -p lib/; ( jar cvf lib/dsdgen.jar tools/ || gjar cvf lib/dsdgen.jar tools/ )

target/tools/dsdgen: target/tpcds_2.10.zip
	test -d target/tools/ || (cd target; unzip tpcds_2.10.zip)
	test -d target/tools/ || (cd target; mv */tools tools)
	cd target/tools; make clean; make dsdgen

clean:
	mvn clean
