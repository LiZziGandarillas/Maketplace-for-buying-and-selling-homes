import React from 'react';

const HouseCard = ({ imageSrc, title, description }) => {
  return (
    <div className="card bg-base-100 w-96 shadow-xl">
      <figure className="px-10 pt-10">
        <img
          src={imageSrc}
          alt={title}
          className="rounded-xl"
        />
      </figure>
      <div className="card-body items-center text-center">
        <h2 className="card-title">{title}</h2>
        <p>{description}</p>
        <div className="card-actions">
          <button className="btn btn-primary">Compra Ahora</button>
        </div>
      </div>
    </div>
  );
};

export default HouseCard;
