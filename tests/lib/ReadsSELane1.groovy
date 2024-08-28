import groovy.transform.InheritConstructors

@InheritConstructors
class ReadsSELane1 extends Reads {
    LinkedHashMap metadata = [
        sampleName:   'SRR1066657',
        sampleNumber: '3',
        lane:         '001',
        readType:     'single'
    ]
    List reads = [
        "tests/data/reads/raw/SRR1066657_S3_L001_R1_001.fastq.gz",
        "tests/data/reads/raw/SRR1066657_S3_L001_R1_001.fastq.gz.NOFILE"
    ]
    LinkedHashMap trimLogs = [
        cutadapt: 'tests/data/reads/trimmed/cutadapt/SRR1066657_L001_cutadapt-log.txt',
        fastp:    'tests/data/reads/trimmed/fastp/SRR1066657_L001_fastp.json',
    ]
}
