import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	pdf: null,
	viewer: null,
	currentPage: 1,
	mounted() {	
		this.initUI();

		const container = this.el.querySelector("#container");
		const url = container.getAttribute("pdf_url");
		pdfjsLib.getDocument(url).promise.then((pdf) => {
			this.pdf = pdf;
			this.showPage(1);
		});
	},
	showPage(idx) {		
		idx = Math.min(Math.max(idx, 1), this.pdf.numPages);
		this.pdf.getPage(idx).then((page) => {
			this.initPDFViewer(page);

			this.viewer.setPdfPage(page);
			this.viewer.draw();
			this.currentPage = idx;
			this.reloadCursorButtonStates();
		});
	},
	initPDFViewer(page) {
		if (this.viewer != null) return;

		const eventBus = new pdfjsViewer.EventBus();
		const linkService = new pdfjsViewer.PDFLinkService({
			eventBus,
		});
		const viewport = page.getViewport({
			scale: window.devicePixelRatio
		});
		const container = this.el.querySelector("#container");
		this.viewer = new pdfjsViewer.PDFPageView({
			container,
			eventBus,
			linkService,
			l10n: pdfjsViewer.NullL10n,
			defaultViewport: viewport
		});
		linkService.setViewer(this.viewer);
		this.reloadCursorButtonStates();
	},
	initUI() {
		const that = this;
		const prevButton = this.el.querySelector("#prev");
		prevButton.addEventListener("click", (e) => {
			that.showPage(that.currentPage-1);
		});
		const nextButton = this.el.querySelector("#next");
		nextButton.addEventListener("click", (e) => {
			that.showPage(that.currentPage+1);
		});

		this.reloadCursorButtonStates();
	},
	reloadCursorButtonStates() {
		const prevButton = this.el.querySelector("#prev");
		prevButton.disabled = (this.currentPage == 1);

		const maxPages = this.pdf ? this.pdf.numPages : 1;
		const nextButton = this.el.querySelector("#next");
		nextButton.disabled = (this.currentPage == maxPages);
	}
}

export default PDFViewer;