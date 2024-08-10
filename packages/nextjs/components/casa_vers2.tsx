import React from 'react';

const CasaCarrusel = ({ images }) => {
  return (
    <div className="carousel w-full">
      {images.map((image, index) => (
        <div key={index} id={`slide${index + 1}`} className="carousel-item relative w-full">
          <img src={image.src} className="w-full" alt={`Slide ${index + 1}`} />
          <div className="absolute left-5 right-5 top-1/2 flex -translate-y-1/2 transform justify-between">
            <a href={`#slide${index === 0 ? images.length : index}`} className="btn btn-circle">❮</a>
            <a href={`#slide${index + 2 > images.length ? 1 : index + 2}`} className="btn btn-circle">❯</a>
          </div>
        </div>
      ))}
    </div>
  );
};

export default CasaCarrusel;
