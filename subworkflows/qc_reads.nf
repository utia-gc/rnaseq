include { compute_bases_genome                             } from '../modules/compute_bases_genome.nf'
include { compute_bases_reads as compute_bases_prealign    } from '../modules/compute_bases_reads.nf'
include { compute_bases_reads as compute_bases_raw         } from '../modules/compute_bases_reads.nf'
include { fastqc              as fastqc_prealign           } from '../modules/fastqc.nf'
include { fastqc              as fastqc_raw                } from '../modules/fastqc.nf'
include { multiqc             as multiqc_reads             } from '../modules/multiqc.nf'
include { Group_Reads         as Group_Reads_Raw           } from '../subworkflows/group_reads.nf'
include { Group_Reads         as Group_Reads_Prealign      } from '../subworkflows/group_reads.nf'

workflow QC_Reads {
    take:
        reads_raw
        reads_prealign
        trim_log
        genome_index

    main:
        fastqc_raw(reads_raw)
        fastqc_prealign(reads_prealign)

        // Compute number of bases in genome if some read depth step is not skipped
        if (params.skipRawReadDepth && params.skipPrealignReadDepth) {
            ch_basesGenome = Channel.empty()
        } else {
            compute_bases_genome(genome_index)
            ch_basesGenome = compute_bases_genome.out.bases
        }

        // Compute read depth of raw reads
        if (params.skipRawReadDepth) {
            ch_sequencingDepthRaw = Channel.empty()
        } else {
            // Count bases in raw reads
            Group_Reads_Raw(reads_raw)
            compute_bases_raw(Group_Reads_Raw.out.reads_grouped)
            // Compute sequencing depth for raw reads
            // Sequencing depth = total number of bases in reads for a sample / total number of bases in the reference genome
            compute_bases_raw.out.bases
                .combine(ch_basesGenome)
                .map { metadata, basesInReads, basesInGenome ->
                    [ metadata, Long.valueOf(basesInReads) / Long.valueOf(basesInGenome) ]
                }
                // write sequencing depth to a file for input to MultiQC
                .collectFile() { metadata, depth ->
                    [
                        "${metadata.sampleName}_raw_seq-depth.tsv",
                        "Sample Name\tDepth\n${metadata.sampleName}\t${depth}"
                    ]
                }
                .set { ch_sequencingDepthRaw }
        }

        // Compute read depth of prealign reads
        if (params.skipPrealignReadDepth) {
            ch_sequencingDepthPrealign = Channel.empty()
        } else {
            // Count bases in prealign reads
            Group_Reads_Prealign(reads_prealign)
            compute_bases_prealign(Group_Reads_Prealign.out.reads_grouped)
            // Compute sequencing depth for prealign reads
            // Sequencing depth = total number of bases in reads for a sample / total number of bases in the reference genome
            compute_bases_prealign.out.bases
                .combine(ch_basesGenome)
                .map { metadata, basesInReads, basesInGenome ->
                    [ metadata, Long.valueOf(basesInReads) / Long.valueOf(basesInGenome) ]
                }
                // write sequencing depth to a file for input to MultiQC
                .collectFile() { metadata, depth ->
                    [
                        "${metadata.sampleName}_prealign_seq-depth.tsv",
                        "Sample Name\tDepth\n${metadata.sampleName}\t${depth}"
                    ]
                }
                .set { ch_sequencingDepthPrealign }
        }

        ch_multiqc_reads = Channel.empty()
            .concat(fastqc_raw.out.zip)
            .concat(fastqc_prealign.out.zip)
            .concat(trim_log)
            .concat(ch_sequencingDepthRaw)
            .concat(ch_sequencingDepthPrealign)
            .collect(
                sort: { a, b ->
                    a.name <=> b.name
                }
            )

        multiqc_reads(
            ch_multiqc_reads,
            file("${projectDir}/assets/multiqc_config.yaml"),
            "reads"
        )

    emit:
        multiqc = ch_multiqc_reads
}
