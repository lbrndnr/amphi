import * as pdfjsLib from 'pdfjs-dist';
import * as pdfjsViewer from 'pdfjs-dist/web/pdf_viewer';

const PDFViewer = {
	mounted() {	
		this.url = this.el.getAttribute("pdf-url");

		pdfjsLib.getDocument(this.url).promise.then((pdf) => {
			this.pdf = pdf;
			this.viewers = Array(this.pdf.numPages);
			this.initContainers();
			for (let i = 0; i < Math.min(this.pdf.numPages, 3); i++) {
				this.loadPage(i);
			}
		});

		const input = this.el.querySelector("#comment-input");
		const button = this.el.querySelector("#comment-button");
		if (input && button) {
			this.commentInput = input;
			button.addEventListener("click", this.submitComment.bind(this));	
		}
	},
	highlightCurrentSelection() {
		const selectionRects = window.getSelection().getRangeAt(0).getClientRects();
		if (selectionRects.length == 0) { return }

		const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
		const y = selectionRects[0].top + scrollTop;
		var idx = null;
		for (let i = 0; i < this.pdf.numPages; i++) {
			const r = this.containers[i].getBoundingClientRect();
			r.y += scrollTop;
			if (r.x < selectionRects[0].left && selectionRects[0].left < (r.x + r.width) && r.y < y && y < (r.y + r.height)) {
				idx = i;
				break;
			}
		}

		if (idx == null) { return }
		
		const viewport = this.viewers[idx].viewport;
		const pageRect = this.viewers[idx].canvas.getClientRects()[0];

		var pdfRects = [];
		for (const r of selectionRects) {
			const min = viewport.convertToPdfPoint(r.left - pageRect.x, r.top - pageRect.y);
			const max = viewport.convertToPdfPoint(r.right - pageRect.x, r.bottom - pageRect.y);
			pdfRects.push(min.concat(max));
		}

		for (const r of pdfRects) {
			this.highlightRect(idx, r, "rgba(1, 0.2, 0.4, 0.3)");
		}

		return pdfRects;
	},
	highlightRect(idx, rect, color) {
		const viewport = this.viewers[idx].viewport;
		const bounds = viewport.convertToViewportRectangle(rect);
		const container = this.containers[idx];
		const page = container.querySelector(".page");
		const attrs = {
			"position": "absolute",
			"background-color": color,
			"left": Math.min(bounds[0], bounds[2]) + "px",
			"top": Math.min(bounds[1], bounds[3]) + "px",
			"width": Math.abs(bounds[0] - bounds[2]) + "px",
			"height": Math.abs(bounds[1] - bounds[3]) + "px",
		}
		const style = Object.keys(attrs).reduce((acc, k) => {
			return acc + `${k}: ${attrs[k]};`
		}, "");
		
		const el = document.createElement("div");
		el.setAttribute("style", style);

		page.appendChild(el);

		return el;
	},
	initContainers() {
		const mainContainer = this.el.querySelector("#pdf-containers");
		this.containers = Array(this.pdf.numPages);
		for (let i = 0; i < this.pdf.numPages; i++) { 
			const elem = document.createElement("div");
			elem.setAttribute("id", `pdf-container-${i}`);
			elem.setAttribute("class", "pdfViewer");
			elem.setAttribute("tabindex", i);
			mainContainer.appendChild(elem);

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
			const viewer = new pdfjsViewer.PDFPageView({
				container,
				eventBus,
				linkService,
				l10n: pdfjsViewer.NullL10n,
				defaultViewport: viewport
			});
			viewer.setPdfPage(page);
			viewer.draw();
			linkService.setViewer(viewer);

			this.viewers[idx] = viewer;
		});
	},
	submitComment(event) {
		const rects = this.highlightCurrentSelection();
		window.getSelection().removeAllRanges();

		const payload = {
			"text": this.commentInput.value,
			"rects": rects.flat()
		};
		this.pushEvent("comment", {"comment": payload});
	}
}

export default PDFViewer;