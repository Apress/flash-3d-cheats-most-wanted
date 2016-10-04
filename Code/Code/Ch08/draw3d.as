Draw3D = function (point_count, face_count) {
	this.scene = createEmptyMovieClip("scene", 1);
	this.scene._x = 200;
	this.scene._y = 200;
	this.face_count = face_count;
	this.point_count = point_count;
	this.faces = new Array (face_count);
	this.points = new Array(3);
	this.points[0] = new Array (point_count);
	this.points[1] = new Array (point_count);
	this.points[2] = new Array (point_count);
	this.x_points = new Array(3);
	this.x_points[0] = new Array (point_count);
	this.x_points[1] = new Array (point_count);
	this.x_points[2] = new Array (point_count);
	this.shade = 0;
	this.fill_r = 0.5;
	this.fill_g = 0.5;
	this.fill_b = 0.5;
	this.fill_a = 100;
	this.line_r = 0.4;
	this.line_g = 0.4;
	this.line_b = 0.4;
	this.line_w = 1;
}

Draw3D.prototype.setPoint = function (i, x, y, z) {
	this.points[0][i] = x;
	this.points[1][i] = y;
	this.points[2][i] = z;
}

Draw3D.prototype.clearTransform = function () {
	for (i=0; i<this.point_count; i++) {
		this.x_points[0][i] = this.points[0][i];
		this.x_points[1][i] = this.points[1][i];
		this.x_points[2][i] = this.points[2][i];
	}
}

Draw3D.prototype.scale = function (sx, sy, sz) {
	for (i=0; i<this.point_count; i++) {
		this.x_points[0][i] *= sx;
		this.x_points[1][i] *= sy;
		this.x_points[2][i] *= sz;
	}
}

Draw3D.prototype.translate = function (tx, ty, tz) {
	for (i=0; i<this.point_count; i++) {
		this.x_points[0][i] += tx;
		this.x_points[1][i] += ty;
		this.x_points[2][i] += tz;
	}
}

Draw3D.prototype.rotateX = function (theta) {
	s = Math.sin(theta);
	c = Math.cos(theta);
	for (i=0; i<this.point_count; i++) {
		y = this.x_points[1][i]*c - this.x_points[2][i]*s;
		z = this.x_points[1][i]*s + this.x_points[2][i]*c;
		this.x_points[2][i] = z;
		this.x_points[1][i] = y;
	}
}

Draw3D.prototype.rotateY = function (theta) {
	s = Math.sin(theta);
	c = Math.cos(theta);
	for (i=0; i<this.point_count; i++) {
		z = this.x_points[2][i]*c - this.x_points[0][i]*s;
		x = this.x_points[2][i]*s + this.x_points[0][i]*c;
		this.x_points[2][i] = z;
		this.x_points[0][i] = x;
	}
}

Draw3D.prototype.rotateZ = function (theta) {
	s = Math.sin(theta);
	c = Math.cos(theta);
	for (i=0; i<this.point_count; i++) {
		x = this.x_points[0][i]*c - this.x_points[1][i]*s;
		y = this.x_points[0][i]*s + this.x_points[1][i]*c;
		this.x_points[0][i] = x;
		this.x_points[1][i] = y;
	}
}

Draw3D.prototype.applyPerspective = function (perspective) {
	for (i=0; i<this.point_count; i++) {
		if (perspective-this.x_points[2][i] == 0) p = 1;
		else p = perspective / (this.x_points[2][i]+perspective);
		if (perspective <= 0) p = 1;
		this.x_points[0][i] *= p;
		this.x_points[1][i] *= p;
	}
}

Draw3D.prototype.setFillColor = function (r, g, b) {
	this.fill_r = r;
	this.fill_g = g;
	this.fill_b = b;
}

Draw3D.prototype.setFillAlpha = function (a) {
	this.fill_a = a;
}

Draw3D.prototype.setLineColor = function (r, g, b) {
	this.line_r = r;
	this.line_g = g;
	this.line_b = b;
}

Draw3D.prototype.setLineWeight = function (w) {
	this.line_w = w;
}

Draw3D.prototype.setShadeOn = function () {
	this.shade = 1;
}

Draw3D.prototype.setShadeOff = function () {
	this.shade = 0;
}

Draw3D.prototype.setFace = function (i, a) {
	this.faces[i] = this.scene.createEmptyMovieClip ("face" + i, i+1);
	this.faces[i].point_count = a.length;
	this.faces[i].shade = this.shade;
	this.faces[i].fill_r = this.fill_r;
	this.faces[i].fill_g = this.fill_g;
	this.faces[i].fill_b = this.fill_b;
	this.faces[i].fill_a = this.fill_a;
	this.faces[i].line_r = this.line_r;
	this.faces[i].line_g = this.line_g;
	this.faces[i].line_b = this.line_b;
	this.faces[i].line_w = this.line_w;
	this.faces[i].points = new Array (point_count);
	for (j=0; j<a.length; j++) {
		this.faces[i].points[j] = a[j];
	}
}

Draw3D.prototype.render = function () {
	p = new Array (3);
	q = new Array (3);
	for (i=0; i<this.face_count; i++) {
		
		// Sort the faces by the average z depth.  This is not
		// correct 100% of the time, but it's pretty good for
		// simple cases.
		depth = this.x_points[2][this.faces[i].points[0]];
		for (j=1; j<this.faces[i].point_count; j++) {
			depth += this.x_points[2][this.faces[i].points[j]];
		}
		depth = 2000 - (depth / this.faces[i].point_count) * 10;
		this.faces[i].swapDepths(Math.floor(depth));
		
		if (this.faces[i].shade) {
			a = this.faces[i].points[0];
			b = this.faces[i].points[1];
			c = this.faces[i].points[2];
			p[0] = this.x_points[0][a] - this.x_points[0][b];
			p[1] = this.x_points[1][a] - this.x_points[1][b];
			p[2] = this.x_points[2][a] - this.x_points[2][b];
			q[0] = this.x_points[0][c] - this.x_points[0][b];
			q[1] = this.x_points[1][c] - this.x_points[1][b];
			q[2] = this.x_points[2][c] - this.x_points[2][b];
			nx = p[1]*q[2] - p[2]*q[1];
			ny = p[2]*q[0] - p[0]*q[2];
			nz = p[0]*q[1] - p[1]*q[0];
			light = Math.abs(nz / Math.sqrt(nx*nx + ny*ny + nz*nz));
		} else {
			light = 1;
		}
		
		this.faces[i].clear();
		if (this.faces[i].line_w > 0) {
			r = Math.floor(this.faces[i].line_r * 255);
			g = Math.floor(this.faces[i].line_g * 255);
			b = Math.floor(this.faces[i].line_b * 255);
			rgb = r*256*256 + g*256 + b;
			this.faces[i].lineStyle (this.faces[i].line_w, rgb);
		}
		r = Math.floor(light * this.faces[i].fill_r * 255);
		g = Math.floor(light * this.faces[i].fill_g * 255);
		b = Math.floor(light * this.faces[i].fill_b * 255);
		rgb = r*256*256 + g*256 + b;
		this.faces[i].beginFill (rgb, this.faces[i].fill_a);
		for (j=0; j<this.faces[i].point_count; j++) {
			pi = this.faces[i].points[j];
			p[0] = this.x_points[0][pi];
			p[1] = this.x_points[1][pi];
			p[2] = this.x_points[2][pi];
			if (j==this.faces[i].point_count-1) qi = this.faces[i].points[0];
			else qi = this.faces[i].points[j+1];
			q[0] = this.x_points[0][qi];
			q[1] = this.x_points[1][qi];
			q[2] = this.x_points[2][qi];
			if (j==0) this.faces[i].moveTo(p[0], p[1]);
			this.faces[i].lineTo(q[0], q[1]);			
		}
		this.faces[i].endFill();
	}
}
