#!make
# Make file with some of the commands I've used.
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Get environment variables (mainly the docker image)
include deepmicrobes.env
export $(shell sed 's/=.*//' deepmicrobes.env)

# We will name the docker images after the commit hashes
GIT_HASH := $(shell git log -1 --format=%h)

.PHONY: clean docker_build docker_login download_examples example_tfrec_predict_kmer example_predict_DeepMicrobes

docker_build:
	docker build . -f docker/Dockerfile -t $(DOCKER_IMAGE_BASE):$(GIT_HASH)

docker_push:
	docker push $(DOCKER_IMAGE_BASE):$(GIT_HASH)
	docker tag $(DOCKER_IMAGE_BASE):$(GIT_HASH) $(DOCKER_IMAGE_BASE):latest
	docker push $(DOCKER_IMAGE_BASE):latest
	
docker_pull:
	docker pull $(DOCKER_IMAGE_BASE):$(DOCKER_IMAGE_TAG)

download_examples: tokens_merged_12mers.txt SRR5935743_clean_1.fastq SRR5935743_clean_2.fastq weights_species
	mkdir -p input/
	mv tokens_merged_12mers.txt input/
	mv SRR5935743_clean_1.fastq input/
	mv SRR5935743_clean_2.fastq input/
	mv weights_species input/

example_tfrec_predict_kmer:
	./dockerDM tfrec_predict_kmer.sh \
 -f input/SRR5935743_clean_1.fastq \
 -r input/SRR5935743_clean_2.fastq \
 -t fastq \
 -v tokens_merged_12mers.txt \
 -o SRR5935743 \
 -s 4000000 \
 -k 12 \
 && mv SRR5935743.tfrec input/
 
example_predict_DeepMicrobes:
	./dockerDM predict_DeepMicrobes.sh \
 -i input/SRR5935743.tfrec \
 -b 8192 \
 -l species \
 -p 8 \
 -m input/weights_species \
 -o SRR5935743 \
 && mv SRR5935743.result.txt output/
	
tokens_merged_12mers.txt:
	wget https://github.com/MicrobeLab/DeepMicrobes-data/raw/master/vocabulary/tokens_merged_12mers.txt.gz
	gunzip tokens_merged_12mers.txt.gz

weights_species:
	wget -O "weights_species.tar.gz" https://onedrive.gimhoy.com/sharepoint/aHR0cHM6Ly9tYWlsMnN5c3VlZHVjbi1teS5zaGFyZXBvaW50LmNvbS86dTovZy9wZXJzb25hbC9saWFuZ3F4N19tYWlsMl9zeXN1X2VkdV9jbi9FU0EtWnZwdVlqcEZqTHlkb2U2Tzl2OEJLOW5PbnFrdkdvOWpuaW56VGE5V0tnP2U9dGo2b3Vo.weights_species.tar.gz
	tar -xzvf weights_species.tar.gz
	rm weights_species.tar.gz

weights_genus:
	wget -O "weights_genus.tar.gz" https://onedrive.gimhoy.com/sharepoint/aHR0cHM6Ly9tYWlsMnN5c3VlZHVjbi1teS5zaGFyZXBvaW50LmNvbS86dTovZy9wZXJzb25hbC9saWFuZ3F4N19tYWlsMl9zeXN1X2VkdV9jbi9FZG12eFdSc0VQeE12QkFlY3JFOFhEMEJwSDVmR0JxLWVUQ0dEcUFVckowdUx3P2U9bExFN0ZC.weights_genus.tar.gz
	tar -xzvf weights_genus.tar.gz
	rm weights_genus.tar.gz

SRR5935743_clean_1.fastq:
	wget https://github.com/MicrobeLab/DeepMicrobes-data/raw/master/gut_metagenome/SRR5935743_clean_1.fastq.gz
	gunzip SRR5935743_clean_1.fastq.gz

SRR5935743_clean_2.fastq:
	wget https://github.com/MicrobeLab/DeepMicrobes-data/raw/master/gut_metagenome/SRR5935743_clean_2.fastq.gz
	gunzip SRR5935743_clean_2.fastq.gz
	
clean:
	@echo "Cleaned -- did nothing"