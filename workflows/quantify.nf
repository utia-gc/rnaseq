include { featureCounts      } from '../modules/featureCounts.nf'
include { make_counts_matrix } from '../modules/make_counts_matrix.nf'


/**
 * Workflow to quantify mappings.
 *
 * This stage is commonly referred to as something like "counting reads."
 * We choose quantify because we find that this encompasses counting reads as well as other methods of quantification, e.g. pseudoalignment
 * 
 * @take alignments the sorted and indexed aligned/mapped reads channel of format [metadata, BAM, BAM.BAI].
 * @take annotations the reference annotations in GTF format. Can be gzipped.
 *
 * @emit quantify_log the output logs/summary/QC files from the quantification tool.
 */
workflow QUANTIFY {
    take:
        alignmentsMergedSortedByName
        annotations

    main:
        featureCounts(
            alignmentsMergedSortedByName,
            annotations
        )

        // collect all of the counts files for input into make_counts_matrix
        featureCounts.out.counts
            .collect(
                // get counts file only -- lose the metadata
                { metadata, counts ->
                    return counts
                },
                // sort based on file name
                sort: { a, b ->
                    a.name <=> b.name
                }
            )
            .set { ch_countsCollected }
        ch_countsCollected.dump(tag: 'ch_countsCollected')

        make_counts_matrix(
            ch_countsCollected,
            params.projectTitle
        )

    emit:
        quantify_log = featureCounts.out.countsSummary
}
