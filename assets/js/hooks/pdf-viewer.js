import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	mounted() {	
		this.url = this.el.getAttribute("pdf-url");

		pdfjsLib.getDocument(this.url).promise.then((pdf) => {
			this.pdf = pdf;
			this.initContainers();
			for (let i = 0; i < this.pdf.numPages; i++) {
				this.loadPage(i);
			}
		});

		document.addEventListener("selectionchange", (event) => {
			const sel = document.getSelection();
			const range = sel.getRangeAt(0); 
			const rect = range.getBoundingClientRect();

			console.log(range, rect);
		});
	},
	initContainers() {
		this.containers = Array(this.pdf.numPages);
		for (let i = 0; i < this.pdf.numPages; i++) { 
			const elem = document.createElement("div");
			elem.setAttribute("class", "pdfViewer");
			this.el.appendChild(elem);

			this.containers[i] = elem;
		  }		
	},
	loadPage(idx) {
		this.pdf.getPage(idx+1).then((page) => {
			const eventBus = new pdfjsViewer.EventBus();
			const linkService = new pdfjsViewer.PDFLinkService({
				eventBus,
			});	
			const viewport = page.getViewport({
				scale: window.devicePixelRatio
			});
			const container = this.containers[idx];
			this.viewer = new pdfjsViewer.PDFPageView({
				container,
				eventBus,
				linkService,
				l10n: pdfjsViewer.NullL10n,
				defaultViewport: viewport
			});
			this.viewer.setPdfPage(page);
			this.viewer.draw();
			linkService.setViewer(this.viewer);
		});
	}
}

export default PDFViewer;